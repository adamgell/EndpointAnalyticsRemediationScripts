[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $PathMap,
    [Parameter(Mandatory)] [string] $PackageData,
    [Parameter(Mandatory)] [string] $OutputPath,
    [string] $BaseRevisionPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$expectedPathCount = 271
$expectedCommandCount = 81
$expectedAliasCount = 12
$expectedAliasPathCount = 9
$expectedFunctionCount = 5

function Test-SafeRepositoryPath {
    param([Parameter(Mandatory)] [string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or
        $Path.Contains('\') -or
        $Path.Contains('"') -or
        [System.IO.Path]::IsPathRooted($Path)) {
        return $false
    }
    foreach ($segment in $Path.Split('/')) {
        if ([string]::IsNullOrWhiteSpace($segment) -or $segment -eq '.' -or $segment -eq '..') {
            return $false
        }
    }
    return $true
}

function Get-FoundationBaseRevision {
    param([Parameter(Mandatory)] [string] $Path)

    if (-not [System.IO.File]::Exists($Path)) {
        throw "Baseline marker '$Path' does not exist."
    }

    $markerBytes = [System.IO.File]::ReadAllBytes($Path)
    $isFullLowercaseSha = $markerBytes.Length -eq 40
    foreach ($byte in $markerBytes) {
        if (-not (
                ($byte -ge [byte][char] '0' -and $byte -le [byte][char] '9') -or
                ($byte -ge [byte][char] 'a' -and $byte -le [byte][char] 'f')
            )) {
            $isFullLowercaseSha = $false
            break
        }
    }
    if (-not $isFullLowercaseSha) {
        throw 'Baseline marker must contain exactly one lowercase 40-character Git commit SHA with no trailing bytes.'
    }

    return [System.Text.Encoding]::ASCII.GetString($markerBytes)
}

function Test-FoundationGitCommit {
    param(
        [Parameter(Mandatory)] [string] $GitDirectory,
        [Parameter(Mandatory)] [string] $Revision
    )

    $escapedGitDirectory = $GitDirectory.Replace('"', '\"')
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'git'
    $startInfo.Arguments = (
        "--no-replace-objects --git-dir=`"$escapedGitDirectory`" rev-parse --verify `"$Revision^{commit}`""
    )
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) {
            throw "Git did not start while validating baseline revision '$Revision'."
        }
        $output = $process.StandardOutput.ReadToEnd().Trim()
        $null = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        return $process.ExitCode -eq 0 -and $output -ceq $Revision
    }
    finally {
        $process.Dispose()
    }
}

function Get-FoundationGitBlobBytes {
    param(
        [Parameter(Mandatory)] [string] $GitDirectory,
        [Parameter(Mandatory)] [string] $Revision,
        [Parameter(Mandatory)] [string] $Path
    )

    $objectName = "$Revision`:$Path"
    $escapedGitDirectory = $GitDirectory.Replace('"', '\"')
    $escapedObjectName = $objectName.Replace('"', '\"')
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'git'
    $startInfo.Arguments = (
        "--no-replace-objects --git-dir=`"$escapedGitDirectory`" cat-file blob `"$escapedObjectName`""
    )
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $memory = New-Object System.IO.MemoryStream
    try {
        if (-not $process.Start()) {
            throw "Git did not start while reading baseline blob '$objectName'."
        }
        $process.StandardOutput.BaseStream.CopyTo($memory)
        $errorText = $process.StandardError.ReadToEnd().Trim()
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) {
            throw "Baseline blob '$objectName' does not exist. Git reported: $errorText"
        }
        return , ($memory.ToArray())
    }
    finally {
        $memory.Dispose()
        $process.Dispose()
    }
}

function ConvertFrom-FoundationScriptBytes {
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [byte[]] $Bytes)

    $encoding = $null
    $offset = 0
    if ($Bytes.Length -ge 4 -and
        $Bytes[0] -eq 0x00 -and $Bytes[1] -eq 0x00 -and
        $Bytes[2] -eq 0xFE -and $Bytes[3] -eq 0xFF) {
        $encoding = New-Object System.Text.UTF32Encoding($true, $true, $true)
        $offset = 4
    }
    elseif ($Bytes.Length -ge 4 -and
        $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE -and
        $Bytes[2] -eq 0x00 -and $Bytes[3] -eq 0x00) {
        $encoding = New-Object System.Text.UTF32Encoding($false, $true, $true)
        $offset = 4
    }
    elseif ($Bytes.Length -ge 3 -and
        $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        $encoding = New-Object System.Text.UTF8Encoding($false, $true)
        $offset = 3
    }
    elseif ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFE -and $Bytes[1] -eq 0xFF) {
        $encoding = New-Object System.Text.UnicodeEncoding($true, $true, $true)
        $offset = 2
    }
    elseif ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE) {
        $encoding = New-Object System.Text.UnicodeEncoding($false, $true, $true)
        $offset = 2
    }
    else {
        foreach ($byte in $Bytes) {
            if ($byte -ge 0x80) {
                throw (
                    'BOM-less non-ASCII baseline source cannot be decoded deterministically ' +
                    'under Windows PowerShell 5.1.'
                )
            }
        }
        $encoding = New-Object System.Text.UTF8Encoding($false, $true)
    }

    return $encoding.GetString($Bytes, $offset, $Bytes.Length - $offset)
}

function Get-CommandRecords {
    param([Parameter(Mandatory)] $Ast)

    $records = New-Object 'System.Collections.Generic.List[object]'
    foreach ($command in @($Ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst]
                }, $true))) {
        $name = $command.GetCommandName()
        if ($null -eq $name -or $command.CommandElements.Count -eq 0) {
            continue
        }
        $records.Add([pscustomobject]@{
                Name = [string] $name
                NameOffset = $command.CommandElements[0].Extent.StartOffset
            })
    }
    return $records.ToArray()
}
function Get-ConstantStringExpressionValue {
    param([Parameter(Mandatory)] $Expression)

    if ($Expression -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
        return [string] $Expression.Value
    }
    if ($Expression -is [System.Management.Automation.Language.ExpandableStringExpressionAst]) {
        if (@($Expression.NestedExpressions).Count -eq 0) {
            return [string] $Expression.Value
        }
        return $null
    }
    if ($Expression -is [System.Management.Automation.Language.BinaryExpressionAst] -and
        $Expression.Operator -eq [System.Management.Automation.Language.TokenKind]::Plus) {
        $left = Get-ConstantStringExpressionValue -Expression $Expression.Left
        $right = Get-ConstantStringExpressionValue -Expression $Expression.Right
        if ($null -ne $left -and $null -ne $right) {
            return $left + $right
        }
        return $null
    }
    if ($Expression -is [System.Management.Automation.Language.ParenExpressionAst]) {
        $pipeline = $Expression.Pipeline
        if ($pipeline -is [System.Management.Automation.Language.PipelineAst] -and
            @($pipeline.PipelineElements).Count -eq 1) {
            $commandExpression = $pipeline.PipelineElements[0]
            if ($commandExpression -is [System.Management.Automation.Language.CommandExpressionAst] -and
                $commandExpression.Expression -is [System.Management.Automation.Language.BinaryExpressionAst] -and
                $commandExpression.Expression.Operator -eq [System.Management.Automation.Language.TokenKind]::Plus) {
                return Get-ConstantStringExpressionValue -Expression $commandExpression.Expression
            }
        }
    }
    return $null
}


function Get-FunctionNameOffset {
    param(
        [Parameter(Mandatory)] $ParsedScript,
        [Parameter(Mandatory)] $Function
    )

    foreach ($token in $ParsedScript.Tokens) {
        if ($token.Extent.StartOffset -le $Function.Extent.StartOffset -or
            $token.Extent.EndOffset -gt $Function.Body.Extent.StartOffset) {
            continue
        }
        if ($token.Text -ceq $Function.Name) {
            return $token.Extent.StartOffset
        }
    }
    return -1
}

function Add-SymbolMapLine {
    param(
        [System.Collections.Generic.List[string]] $Lines,
        [Parameter(Mandatory)] $Row,
        [Parameter(Mandatory)] [bool] $IncludeOccurrence
    )

    $path = ([string] $Row.Path).Replace("'", "''")
    $oldName = ([string] $Row.OldName).Replace("'", "''")
    $newName = ([string] $Row.NewName).Replace("'", "''")
    $Lines.Add('        @{')
    $Lines.Add("            Path = '$path'")
    $Lines.Add("            OldName = '$oldName'")
    $Lines.Add("            NewName = '$newName'")
    if ($IncludeOccurrence) {
        $Lines.Add("            Occurrence = $($Row.Occurrence)")
    }
    $Lines.Add('        }')
}

function Set-SymbolRowOrder {
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]] $Rows,
        [Parameter(Mandatory)] [bool] $HasOccurrence
    )

    $comparison = [System.Comparison[object]] {
        param($left, $right)

        $result = [System.StringComparer]::Ordinal.Compare([string] $left.Path, [string] $right.Path)
        if ($result -ne 0) {
            return $result
        }
        if ($HasOccurrence) {
            $result = ([int] $left.Occurrence).CompareTo([int] $right.Occurrence)
            if ($result -ne 0) {
                return $result
            }
        }
        $result = [System.StringComparer]::Ordinal.Compare([string] $left.OldName, [string] $right.OldName)
        if ($result -ne 0) {
            return $result
        }
        return [System.StringComparer]::Ordinal.Compare([string] $left.NewName, [string] $right.NewName)
    }
    $Rows.Sort($comparison)
}

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Import-Module (Join-Path $PSScriptRoot 'RepositoryCatalog.psm1') -Force
if ([string]::IsNullOrWhiteSpace($BaseRevisionPath)) {
    $BaseRevisionPath = Join-Path $repositoryRoot 'evidence/foundation/BaseRevision.txt'
}
$baseRevision = Get-FoundationBaseRevision -Path $BaseRevisionPath
$gitContext = Resolve-FoundationRepositoryGitContext -RepositoryRoot $repositoryRoot
$baselineCommitExists = Test-FoundationGitCommit `
    -GitDirectory $gitContext.GitDirectory `
    -Revision $baseRevision
if (-not $baselineCommitExists) {
    throw "Baseline revision '$baseRevision' does not exist or is not a commit."
}

$pathData = Import-PowerShellDataFile -Path $PathMap
$packageDataContent = Import-PowerShellDataFile -Path $PackageData
if (-not $pathData.ContainsKey('Paths')) {
    throw "Path map is missing 'Paths'."
}
foreach ($requiredKey in 'CanonicalCmdlets', 'CanonicalAliases', 'AliasMappings', 'FunctionMappings') {
    if (-not $packageDataContent.ContainsKey($requiredKey)) {
        throw "Package data is missing '$requiredKey'."
    }
}

$pathRows = @($pathData.Paths)
if ($pathRows.Count -ne $expectedPathCount) {
    throw "Expected $expectedPathCount path rows; found $($pathRows.Count)."
}
$sourcePaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$destinationPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$parsedByDestination = [System.Collections.Generic.Dictionary[string, object]]::new(
    [System.StringComparer]::Ordinal
)
foreach ($pathRow in $pathRows) {
    $basePath = [string] $pathRow.BasePath
    $newPath = [string] $pathRow.NewPath
    if (-not (Test-SafeRepositoryPath -Path $basePath) -or -not (Test-SafeRepositoryPath -Path $newPath)) {
        throw "Path map contains unsafe row '$basePath' -> '$newPath'."
    }
    if ([System.StringComparer]::OrdinalIgnoreCase.Equals($basePath, $newPath)) {
        throw "Path map row '$basePath' uses indistinguishable source and destination paths."
    }
    if (-not $sourcePaths.Add($basePath)) {
        throw "Path map source '$basePath' is duplicated or case-colliding."
    }
    if (-not $destinationPaths.Add($newPath)) {
        throw "Path map destination '$newPath' is duplicated or case-colliding."
    }

    $sourceBytes = Get-FoundationGitBlobBytes `
        -GitDirectory $gitContext.GitDirectory `
        -Revision $baseRevision `
        -Path $basePath
    try {
        $sourceText = ConvertFrom-FoundationScriptBytes -Bytes $sourceBytes
    }
    catch {
        throw "Baseline blob '$baseRevision`:$basePath' could not be decoded: $($_.Exception.Message)"
    }

    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput(
        $sourceText,
        $basePath,
        [ref] $tokens,
        [ref] $parseErrors
    )
    if (@($parseErrors).Count -gt 0) {
        $messages = @($parseErrors | ForEach-Object Message) -join '; '
        throw "Baseline blob '$baseRevision`:$basePath' has parser errors: $messages"
    }

    $parsedByDestination.Add($newPath, [pscustomobject]@{
            BasePath = $basePath
            NewPath = $newPath
            Ast = $ast
            Tokens = @($tokens)
            Commands = @(Get-CommandRecords -Ast $ast)
            Functions = @($ast.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
                    }, $true))
        })
}

$canonicalCmdlets = [System.Collections.Generic.Dictionary[string, string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
foreach ($canonicalName in @($packageDataContent.CanonicalCmdlets)) {
    $name = [string] $canonicalName
    if ([string]::IsNullOrWhiteSpace($name) -or $name -notmatch '^[A-Za-z]+-[A-Za-z0-9]+$') {
        throw "Canonical cmdlet name '$name' is invalid."
    }
    if ($canonicalCmdlets.ContainsKey($name)) {
        throw "Canonical cmdlet name '$name' is duplicated or case-colliding."
    }
    $canonicalCmdlets.Add($name, $name)
}

$knownAliases = [System.Collections.Generic.Dictionary[string, string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
foreach ($aliasName in @($packageDataContent.CanonicalAliases.Keys)) {
    $name = [string] $aliasName
    $resolvedCommandName = [string] $packageDataContent.CanonicalAliases[$aliasName]
    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($resolvedCommandName)) {
        throw "Canonical alias '$name' is incomplete."
    }
    if ($knownAliases.ContainsKey($name)) {
        throw "Canonical alias '$name' is duplicated or case-colliding."
    }
    $knownAliases.Add($name, $resolvedCommandName)
}

$configuredAliases = [System.Collections.Generic.Dictionary[string, object]]::new(
    [System.StringComparer]::Ordinal
)
foreach ($mapping in @($packageDataContent.AliasMappings)) {
    $path = [string] $mapping.Path
    $oldName = [string] $mapping.OldName
    $newName = [string] $mapping.NewName
    $occurrence = 0
    if (-not $parsedByDestination.ContainsKey($path) -or
        [string]::IsNullOrWhiteSpace($oldName) -or
        [string]::IsNullOrWhiteSpace($newName) -or
        -not [int]::TryParse([string] $mapping.Occurrence, [ref] $occurrence) -or
        $occurrence -lt 1) {
        throw "Alias mapping '$path|$oldName' is incomplete or targets an unmapped destination."
    }

    if (-not $knownAliases.ContainsKey($oldName)) {
        throw "Alias '$oldName' is not present in the pinned canonical alias catalog."
    }
    if ($knownAliases[$oldName] -cne $newName) {
        throw "Alias '$oldName' resolves to '$($knownAliases[$oldName])', not '$newName'."
    }

    $key = $path + [char] 0 + $oldName.ToLowerInvariant() + [char] 0 + $occurrence
    if ($configuredAliases.ContainsKey($key)) {
        throw "Alias mapping '$path|$oldName|$occurrence' is duplicated."
    }
    $configuredAliases.Add($key, [pscustomobject]@{
            Path = $path
            OldName = $oldName
            NewName = $newName
            Occurrence = $occurrence
        })
}
if ($configuredAliases.Count -ne $expectedAliasCount) {
    throw "Expected $expectedAliasCount reviewed alias mappings; found $($configuredAliases.Count)."
}

$commandRows = New-Object 'System.Collections.Generic.List[object]'
$aliasRows = New-Object 'System.Collections.Generic.List[object]'
$discoveredAliases = [System.Collections.Generic.Dictionary[string, object]]::new(
    [System.StringComparer]::Ordinal
)
foreach ($parsed in $parsedByDestination.Values) {
    $localFunctions = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($function in $parsed.Functions) {
        $null = $localFunctions.Add([string] $function.Name)
    }

    $commandOccurrences = [System.Collections.Generic.Dictionary[string, int]]::new(
        [System.StringComparer]::Ordinal
    )
    $aliasOccurrences = [System.Collections.Generic.Dictionary[string, int]]::new(
        [System.StringComparer]::Ordinal
    )
    foreach ($command in $parsed.Commands) {
        $name = [string] $command.Name
        if ($localFunctions.Contains($name)) {
            continue
        }

        if ($knownAliases.ContainsKey($name)) {
            $occurrenceKey = $name.ToLowerInvariant()
            $occurrence = 1
            if ($aliasOccurrences.ContainsKey($occurrenceKey)) {
                $occurrence = $aliasOccurrences[$occurrenceKey] + 1
            }
            $aliasOccurrences[$occurrenceKey] = $occurrence
            $row = [pscustomobject]@{
                Path = [string] $parsed.NewPath
                OldName = $name
                NewName = $knownAliases[$name]
                Occurrence = $occurrence
            }
            $rowKey = $row.Path + [char] 0 + $name.ToLowerInvariant() + [char] 0 + $occurrence
            if ($discoveredAliases.ContainsKey($rowKey)) {
                throw "Alias occurrence '$($row.Path)|$name|$occurrence' is duplicated."
            }
            $discoveredAliases.Add($rowKey, $row)
            $aliasRows.Add($row)
            continue
        }

        if ($canonicalCmdlets.ContainsKey($name) -and $name -cne $canonicalCmdlets[$name]) {
            $occurrenceKey = $name
            $occurrence = 1
            if ($commandOccurrences.ContainsKey($occurrenceKey)) {
                $occurrence = $commandOccurrences[$occurrenceKey] + 1
            }
            $commandOccurrences[$occurrenceKey] = $occurrence
            $commandRows.Add([pscustomobject]@{
                    Path = [string] $parsed.NewPath
                    OldName = $name
                    NewName = $canonicalCmdlets[$name]
                    Occurrence = $occurrence
                })
        }
    }
}

if ($commandRows.Count -ne $expectedCommandCount) {
    throw "Expected $expectedCommandCount cmdlet-casing mappings; found $($commandRows.Count)."
}
if ($discoveredAliases.Count -ne $configuredAliases.Count) {
    throw "Discovered $($discoveredAliases.Count) alias occurrences; expected $($configuredAliases.Count)."
}
foreach ($key in $configuredAliases.Keys) {
    if (-not $discoveredAliases.ContainsKey($key)) {
        $configured = $configuredAliases[$key]
        throw "Reviewed alias '$($configured.Path)|$($configured.OldName)|$($configured.Occurrence)' was not found."
    }
    $configured = $configuredAliases[$key]
    $discovered = $discoveredAliases[$key]
    if (
        $discovered.OldName -cne $configured.OldName -or
        $discovered.NewName -cne $configured.NewName
    ) {
        throw (
            "Alias occurrence '$($configured.Path)|$($configured.OldName)|" +
            "$($configured.Occurrence)' differs from the reviewed mapping."
        )
    }
}
$aliasRows.Clear()
foreach ($configured in $configuredAliases.Values) {
    $aliasRows.Add($configured)
}
$aliasPathSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($row in $aliasRows) {
    $null = $aliasPathSet.Add([string] $row.Path)
}
if ($aliasPathSet.Count -ne $expectedAliasPathCount) {
    throw "Expected alias mappings across $expectedAliasPathCount files; found $($aliasPathSet.Count)."
}

$functionRows = New-Object 'System.Collections.Generic.List[object]'
$configuredFunctions = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($mapping in @($packageDataContent.FunctionMappings)) {
    $path = [string] $mapping.Path
    $oldName = [string] $mapping.OldName
    $newName = [string] $mapping.NewName
    if (-not $parsedByDestination.ContainsKey($path) -or
        [string]::IsNullOrWhiteSpace($oldName) -or
        [string]::IsNullOrWhiteSpace($newName)) {
        throw "Function mapping '$path|$oldName' is incomplete or targets an unmapped destination."
    }
    $key = $path + [char] 0 + $oldName.ToLowerInvariant()
    if (-not $configuredFunctions.Add($key)) {
        throw "Function mapping '$path|$oldName' is duplicated."
    }

    $parsed = $parsedByDestination[$path]
    $definitions = @($parsed.Functions | Where-Object Name -IEQ $oldName)
    if ($definitions.Count -ne 1) {
        throw "Function mapping '$path|$oldName' requires exactly one definition; found $($definitions.Count)."
    }
    $calls = @($parsed.Commands | Where-Object Name -IEQ $oldName)
    if ($calls.Count -lt 1) {
        throw "Function mapping '$path|$oldName' has no static callsites."
    }

    $allowedOffsets = [System.Collections.Generic.HashSet[int]]::new()
    $definitionOffset = Get-FunctionNameOffset -ParsedScript $parsed -Function $definitions[0]
    if ($definitionOffset -lt 0) {
        throw "Function mapping '$path|$oldName' has no identifiable definition token."
    }
    $null = $allowedOffsets.Add($definitionOffset)
    foreach ($call in $calls) {
        $null = $allowedOffsets.Add([int] $call.NameOffset)
    }

    $symbolPattern = '(?i)(?<![A-Za-z0-9_-])' + [regex]::Escape($oldName) + '(?![A-Za-z0-9_-])'
    $memberOffsets = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($memberExpression in @($parsed.Ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.MemberExpressionAst]
                }, $true))) {
        if ($null -ne $memberExpression.Member) {
            $null = $memberOffsets.Add([int] $memberExpression.Member.Extent.StartOffset)
        }
    }

    foreach ($command in @($parsed.Ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst]
                }, $true))) {
        if ($command.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Unknown -or
            $command.CommandElements.Count -eq 0 -or $null -ne $command.GetCommandName()) {
            continue
        }
        $constantTarget = Get-ConstantStringExpressionValue `
            -Expression $command.CommandElements[0]
        if ($null -ne $constantTarget -and [regex]::IsMatch($constantTarget, $symbolPattern)) {
            throw "Function mapping '$path|$oldName' has an ambiguous or non-static reference."
        }
    }

    foreach ($token in $parsed.Tokens) {
        if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::EndOfInput -or
            $token.Kind -eq [System.Management.Automation.Language.TokenKind]::Variable -or
            $memberOffsets.Contains([int] $token.Extent.StartOffset)) {
            continue
        }
        if ([regex]::IsMatch([string] $token.Text, $symbolPattern) -and
            -not $allowedOffsets.Contains([int] $token.Extent.StartOffset)) {
            throw "Function mapping '$path|$oldName' has an ambiguous or non-static reference."
        }
    }

    $functionRows.Add([pscustomobject]@{
            Path = $path
            OldName = $oldName
            NewName = $newName
        })
}
if ($functionRows.Count -ne $expectedFunctionCount) {
    throw "Expected $expectedFunctionCount reviewed function mappings; found $($functionRows.Count)."
}

Set-SymbolRowOrder -Rows $commandRows -HasOccurrence $true
Set-SymbolRowOrder -Rows $aliasRows -HasOccurrence $true
Set-SymbolRowOrder -Rows $functionRows -HasOccurrence $false

$lines = New-Object 'System.Collections.Generic.List[string]'
$lines.Add('@{')
$lines.Add('    Commands = @(')
foreach ($row in $commandRows) {
    Add-SymbolMapLine -Lines $lines -Row $row -IncludeOccurrence $true
}
$lines.Add('    )')
$lines.Add('')
$lines.Add('    Aliases = @(')
foreach ($row in $aliasRows) {
    Add-SymbolMapLine -Lines $lines -Row $row -IncludeOccurrence $true
}
$lines.Add('    )')
$lines.Add('')
$lines.Add('    Functions = @(')
foreach ($row in $functionRows) {
    Add-SymbolMapLine -Lines $lines -Row $row -IncludeOccurrence $false
}
$lines.Add('    )')
$lines.Add('}')

$outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
$outputDirectory = [System.IO.Path]::GetDirectoryName($outputFullPath)
if (-not [string]::IsNullOrEmpty($outputDirectory)) {
    [System.IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
}
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outputFullPath, (($lines -join "`n") + "`n"), $utf8WithoutBom)
Write-Output (
    'Generated {0} command, {1} alias, and {2} function mappings.' -f
    $commandRows.Count,
    $aliasRows.Count,
    $functionRows.Count
)
