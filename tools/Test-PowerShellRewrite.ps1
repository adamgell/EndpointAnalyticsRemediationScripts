[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $BaseRevision,
    [Parameter(Mandatory)] [string] $PathMap,
    [Parameter(Mandatory)] [string] $SymbolMap,
    [Parameter(Mandatory)] [string] $ReportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot/RewriteEquivalence.psm1" -Force

function Resolve-FullGitRevision {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $RepositoryRoot,
        [Parameter(Mandatory)] [string] $Revision
    )

    $output = @(& git -C $RepositoryRoot rev-parse --verify "$Revision^{commit}" 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve base revision '$Revision': $($output -join ' ')"
    }

    $fullRevision = ([string] $output[0]).Trim()
    if ($fullRevision -cnotmatch '^[0-9a-f]{40}$') {
        throw "Base revision '$Revision' did not resolve to a full 40-character SHA."
    }
    return $fullRevision
}

function Get-GitBlobBytes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $RepositoryRoot,
        [Parameter(Mandatory)] [string] $Revision,
        [Parameter(Mandatory)] [string] $Path
    )

    $escapedRoot = $RepositoryRoot.Replace('"', '\"')
    $escapedObject = ("$Revision`:$Path").Replace('"', '\"')
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'git'
    $startInfo.Arguments = "-C `"$escapedRoot`" cat-file blob `"$escapedObject`""
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $memory = New-Object System.IO.MemoryStream
    try {
        if (-not $process.Start()) {
            throw 'Git blob process did not start.'
        }
        $process.StandardOutput.BaseStream.CopyTo($memory)
        $errorText = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) {
            throw "Could not read Git blob '$Revision`:$Path': $errorText"
        }
        return , ($memory.ToArray())
    }
    finally {
        $memory.Dispose()
        $process.Dispose()
    }
}

function Get-SymbolMapEntryPath {
    param([Parameter(Mandatory)] $Row)

    if ($Row -is [System.Collections.IDictionary] -and $Row.Contains('Path')) {
        return [string] $Row['Path']
    }
    $pathProperty = $Row.PSObject.Properties['Path']
    if ($null -ne $pathProperty) {
        return [string] $pathProperty.Value
    }
    return $null
}

function Get-OrdinalSortedPathRows {
    param([Parameter(Mandatory)] [object[]] $Rows)

    $sortedRows = New-Object 'System.Collections.Generic.List[object]'
    foreach ($row in $Rows) {
        $sortedRows.Add($row)
    }
    $comparison = [System.Comparison[object]] {
        param($left, $right)
        return [System.StringComparer]::Ordinal.Compare(
            [string] $left.NewPath,
            [string] $right.NewPath
        )
    }
    $sortedRows.Sort($comparison)
    return , ($sortedRows.ToArray())
}

function Test-FunctionCommandName {
    param(
        [Parameter(Mandatory)] [string] $CommandName,
        [Parameter(Mandatory)] [string] $FunctionName
    )

    $suffixStart = $CommandName.Length - $FunctionName.Length
    if ($suffixStart -lt 0 -or
        $CommandName.Substring($suffixStart) -ine $FunctionName) {
        return $false
    }
    if ($suffixStart -eq 0) {
        return $true
    }

    $separator = $CommandName[$suffixStart - 1]
    return $separator -eq ':' -or $separator -eq '\'
}

function Test-PowerShellFunctionReference {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $FunctionName
    )

    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput(
        [System.IO.File]::ReadAllText($Path),
        [ref] $tokens,
        [ref] $parseErrors
    )
    $functions = @($ast.FindAll({
                param($node)
                $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
            }, $true))
    if (@($functions | Where-Object { $_.Name -ieq $FunctionName }).Count -gt 0) {
        return $true
    }

    $symbolPattern = '(?i)(?<![A-Za-z0-9_-])' + [regex]::Escape($FunctionName) + '(?![A-Za-z0-9_-])'
    $commands = @($ast.FindAll({
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst]
            }, $true))
    foreach ($command in $commands) {
        $commandName = $command.GetCommandName()
        if ($null -ne $commandName -and
            (Test-FunctionCommandName -CommandName $commandName -FunctionName $FunctionName)) {
            return $true
        }
        if ($command.InvocationOperator -ne [System.Management.Automation.Language.TokenKind]::Unknown -and
            $command.CommandElements.Count -gt 0 -and
            [regex]::IsMatch([string] $command.CommandElements[0].Extent.Text, $symbolPattern)) {
            return $true
        }
    }

    $stringExpressions = @($ast.FindAll({
                param($node)
                ($node -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
                -not ($node.Parent -is [System.Management.Automation.Language.MemberExpressionAst] -and
                    [object]::ReferenceEquals($node.Parent.Member, $node))) -or
                $node -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
            }, $true))
    foreach ($stringExpression in $stringExpressions) {
        if ($stringExpression -is [System.Management.Automation.Language.ExpandableStringExpressionAst]) {
            $literalCharacters = $stringExpression.Extent.Text.ToCharArray()
            foreach ($nestedExpression in @($stringExpression.NestedExpressions)) {
                $relativeStart = $nestedExpression.Extent.StartOffset - $stringExpression.Extent.StartOffset
                $relativeEnd = $nestedExpression.Extent.EndOffset - $stringExpression.Extent.StartOffset
                for ($index = $relativeStart; $index -lt $relativeEnd; $index++) {
                    $literalCharacters[$index] = ' '
                }
            }
            $literalTokens = $null
            $literalErrors = $null
            $literalAst = [System.Management.Automation.Language.Parser]::ParseInput(
                (-join $literalCharacters),
                [ref] $literalTokens,
                [ref] $literalErrors
            )
            $parsedLiteralExpressions = @($literalAst.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
                        $node -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
                    }, $true))
            if (@($literalErrors).Count -eq 0 -and $parsedLiteralExpressions.Count -eq 1) {
                $literalText = [string] $parsedLiteralExpressions[0].Value
            }
            else {
                $literalText = -join $literalCharacters
            }
        }
        else {
            $literalText = [string] $stringExpression.Value
        }
        if ([regex]::IsMatch($literalText, $symbolPattern)) {
            return $true
        }
    }

    return $false
}

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$fullRevision = ''
$rows = @()
$gateFailures = New-Object 'System.Collections.Generic.List[string]'

try {
    $fullRevision = Resolve-FullGitRevision -RepositoryRoot $repositoryRoot -Revision $BaseRevision
    $pathMapData = Import-PowerShellDataFile -Path $PathMap
    $symbolMapData = Import-PowerShellDataFile -Path $SymbolMap
    $pathRows = @($pathMapData.Paths)

    if (-not (Test-PathMapBijection -Rows $pathRows -ExpectedCount $pathRows.Count)) {
        throw 'Path map is not a total bijection of safe repository-relative paths.'
    }

    $infrastructureDirectories = @(
        '.git', '.github', '.superpowers', 'assets', 'docs', 'evidence', 'standards', 'tests', 'tools'
    )

    $treeOutput = @(& git -C $repositoryRoot ls-tree -r --name-only $fullRevision 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Could not enumerate base revision '$fullRevision': $($treeOutput -join ' ')"
    }
    $baseInventory = @($treeOutput | Where-Object {
            $path = [string] $_
            if ($path -notmatch '/') { return $false }
            $topLevel = $path.Split('/')[0]
            if ($topLevel -in $infrastructureDirectories) { return $false }
            $extension = [System.IO.Path]::GetExtension($path)
            return $extension -eq '.ps1' -or [string]::IsNullOrEmpty($extension)
        } | Sort-Object)

    $currentInventory = New-Object 'System.Collections.Generic.List[string]'
    foreach ($directory in Get-ChildItem -LiteralPath $repositoryRoot -Directory) {
        if ($directory.Name -in $infrastructureDirectories) {
            continue
        }
        foreach ($file in Get-ChildItem -LiteralPath $directory.FullName -Recurse -File) {
            if ($file.Extension -ne '.ps1' -and -not [string]::IsNullOrEmpty($file.Extension)) {
                continue
            }
            $relativePath = $file.FullName.Substring($repositoryRoot.Length).TrimStart('\', '/').Replace('\', '/')
            $currentInventory.Add($relativePath)
        }
    }

    $mappedBase = @($pathRows.BasePath | Sort-Object)
    $mappedNew = @($pathRows.NewPath | Sort-Object)
    $currentInventoryArray = @($currentInventory | Sort-Object)
    if (@(Compare-Object -ReferenceObject $baseInventory -DifferenceObject $mappedBase -CaseSensitive).Count -gt 0) {
        throw 'Path map source inventory does not equal the base revision runtime inventory.'
    }
    if (@(
            Compare-Object `
                -ReferenceObject $currentInventoryArray `
                -DifferenceObject $mappedNew `
                -CaseSensitive
        ).Count -gt 0) {
        throw 'Path map destination inventory does not equal the working-tree runtime inventory.'
    }

    $declaredMappings = New-Object 'System.Collections.Generic.List[object]'
    foreach ($mappingType in @('Commands', 'Aliases', 'Functions')) {
        if (-not $symbolMapData.ContainsKey($mappingType)) {
            continue
        }
        foreach ($mapping in @($symbolMapData[$mappingType])) {
            $mappingPath = Get-SymbolMapEntryPath -Row $mapping
            if ([string]::IsNullOrWhiteSpace($mappingPath)) {
                throw "Symbol map $mappingType entry is missing its destination Path."
            }
            if ($mappedNew -cnotcontains $mappingPath) {
                throw "Symbol map $mappingType entry targets unmapped destination '$mappingPath'."
            }
            $declaredMappings.Add($mapping)
        }
    }

    $orderedPathRows = Get-OrdinalSortedPathRows -Rows $pathRows
    $comparisonRows = New-Object 'System.Collections.Generic.List[object]'
    foreach ($pathRow in $orderedPathRows) {
        $scopedSymbolMap = @{}
        foreach ($mappingType in @('Commands', 'Aliases', 'Functions')) {
            $allMappings = @()
            if ($symbolMapData.ContainsKey($mappingType)) {
                $allMappings = @($symbolMapData[$mappingType])
            }
            $scopedSymbolMap[$mappingType] = @($allMappings | Where-Object {
                    (Get-SymbolMapEntryPath -Row $_) -ceq [string] $pathRow.NewPath
                })
        }

        $beforeBytes = Get-GitBlobBytes `
            -RepositoryRoot $repositoryRoot `
            -Revision $fullRevision `
            -Path ([string] $pathRow.BasePath)
        $afterRelativePath = ([string] $pathRow.NewPath).Replace(
            '/',
            [System.IO.Path]::DirectorySeparatorChar
        )
        $afterPath = Join-Path $repositoryRoot $afterRelativePath
        if (-not (Test-Path -LiteralPath $afterPath -PathType Leaf)) {
            throw "Mapped destination '$($pathRow.NewPath)' does not exist."
        }

        $comparisonRows.Add((Compare-PowerShellSource `
                    -BeforePath ([string] $pathRow.BasePath) `
                    -AfterPath ([string] $pathRow.NewPath) `
                    -BeforeBytes $beforeBytes `
                    -AfterBytes ([System.IO.File]::ReadAllBytes($afterPath)) `
                    -SymbolMap $scopedSymbolMap))
    }
    $rows = $comparisonRows.ToArray()

    $appliedMappingCount = 0
    foreach ($comparisonRow in $rows) {
        $appliedMappingCount += @($comparisonRow.AppliedMapEntries).Count
    }
    if ($appliedMappingCount -ne $declaredMappings.Count) {
        $gateFailures.Add('Every symbol map entry must apply exactly once at its declared destination path.')
    }

    $catalogReferences = New-Object 'System.Collections.Generic.List[object]'
    foreach ($directory in Get-ChildItem -LiteralPath $repositoryRoot -Directory) {
        if ($directory.Name -in $infrastructureDirectories) {
            continue
        }
        foreach ($file in Get-ChildItem -LiteralPath $directory.FullName -Recurse -File) {
            if ($file.Extension -in @('.ps1', '.psd1', '.md')) {
                $relativePath = $file.FullName.Substring($repositoryRoot.Length).TrimStart('\', '/').Replace('\', '/')
                $catalogReferences.Add([pscustomobject]@{
                        File = $file
                        RelativePath = $relativePath
                    })
            }
        }
    }
    $catalogReferenceComparison = [System.Comparison[object]] {
        param($left, $right)
        return [System.StringComparer]::Ordinal.Compare(
            [string] $left.RelativePath,
            [string] $right.RelativePath
        )
    }
    $catalogReferences.Sort($catalogReferenceComparison)
    if ($symbolMapData.ContainsKey('Functions')) {
        foreach ($mapping in @($symbolMapData.Functions)) {
            $oldName = [string] $mapping.OldName
            $pattern = '(?i)(?<![A-Za-z0-9_-])' + [regex]::Escape($oldName) + '(?![A-Za-z0-9_-])'
            foreach ($reference in $catalogReferences) {
                if ($reference.File.Extension -eq '.ps1') {
                    $containsReference = Test-PowerShellFunctionReference `
                        -Path $reference.File.FullName `
                        -FunctionName $oldName
                }
                else {
                    $containsReference = [regex]::IsMatch(
                        [System.IO.File]::ReadAllText($reference.File.FullName),
                        $pattern
                    )
                }
                if ($containsReference) {
                    $gateFailures.Add(
                        "Catalog file '$($reference.RelativePath)' contains unresolved old function symbol '$oldName'."
                    )
                }
            }
        }
    }
}
catch {
    $gateFailures.Add($_.Exception.Message)
}

$failedRows = @($rows | Where-Object { -not $_.Passed })
$passed = $gateFailures.Count -eq 0 -and $rows.Count -gt 0 -and $failedRows.Count -eq 0
$report = [pscustomobject][ordered]@{
    SchemaVersion = 1
    BaseRevision = $fullRevision
    Passed = $passed
    Failures = @($gateFailures | Select-Object -Unique)
    Rows = @($rows)
}

$reportFullPath = if ([System.IO.Path]::IsPathRooted($ReportPath)) {
    [System.IO.Path]::GetFullPath($ReportPath)
}
else {
    [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $ReportPath))
}
$reportDirectory = [System.IO.Path]::GetDirectoryName($reportFullPath)
if (-not [string]::IsNullOrEmpty($reportDirectory)) {
    [System.IO.Directory]::CreateDirectory($reportDirectory) | Out-Null
}
$json = $report | ConvertTo-Json -Depth 12
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($reportFullPath, $json + "`n", $utf8WithoutBom)

if ($passed) {
    exit 0
}
exit 1
