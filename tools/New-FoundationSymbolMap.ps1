[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $PathMap,
    [Parameter(Mandatory)] [string] $PackageData,
    [Parameter(Mandatory)] [string] $OutputPath
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
        [System.IO.Path]::IsPathRooted($Path) -or
        $Path.Contains('\')) {
        return $false
    }
    foreach ($segment in $Path.Split('/')) {
        if ([string]::IsNullOrWhiteSpace($segment) -or $segment -eq '.' -or $segment -eq '..') {
            return $false
        }
    }
    return $true
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
    if ($IncludeOccurrence) {
        $Lines.Add("        @{ Path = '$path'; OldName = '$oldName'; NewName = '$newName'; Occurrence = $($Row.Occurrence) }")
    }
    else {
        $Lines.Add("        @{ Path = '$path'; OldName = '$oldName'; NewName = '$newName' }")
    }
}

function Sort-SymbolRows {
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

    $sourceFullPath = Join-Path $repositoryRoot $basePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    $destinationFullPath = Join-Path $repositoryRoot $newPath.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    $sourceExists = [System.IO.File]::Exists($sourceFullPath)
    $destinationExists = [System.IO.File]::Exists($destinationFullPath)
    if ($sourceExists -and $destinationExists) {
        $sourceBytes = [System.IO.File]::ReadAllBytes($sourceFullPath)
        $destinationBytes = [System.IO.File]::ReadAllBytes($destinationFullPath)
        $contentMatches = $sourceBytes.Length -eq $destinationBytes.Length
        for ($index = 0; $contentMatches -and $index -lt $sourceBytes.Length; $index++) {
            if ($sourceBytes[$index] -ne $destinationBytes[$index]) {
                $contentMatches = $false
            }
        }
        if (-not $contentMatches) {
            throw "Mapped source '$basePath' and destination '$newPath' both exist with different content."
        }
        throw "Mapped source '$basePath' and destination '$newPath' both exist unexpectedly."
    }
    if (-not $sourceExists -and -not $destinationExists) {
        throw "Neither mapped source '$basePath' nor destination '$newPath' exists."
    }

    $parseFullPath = if ($sourceExists) { $sourceFullPath } else { $destinationFullPath }
    $parseRelativePath = if ($sourceExists) { $basePath } else { $newPath }
    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        $parseFullPath,
        [ref] $tokens,
        [ref] $parseErrors
    )
    if (@($parseErrors).Count -gt 0) {
        $messages = @($parseErrors | ForEach-Object Message) -join '; '
        throw "Mapped file '$parseRelativePath' has parser errors: $messages"
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
    if ($discovered.OldName -cne $configured.OldName -or $discovered.NewName -cne $configured.NewName) {
        throw "Alias occurrence '$($configured.Path)|$($configured.OldName)|$($configured.Occurrence)' differs from the reviewed mapping."
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
    foreach ($token in $parsed.Tokens) {
        if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::EndOfInput -or
            $token.Kind -eq [System.Management.Automation.Language.TokenKind]::Variable) {
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

Sort-SymbolRows -Rows $commandRows -HasOccurrence $true
Sort-SymbolRows -Rows $aliasRows -HasOccurrence $true
Sort-SymbolRows -Rows $functionRows -HasOccurrence $false

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
Write-Output "Generated $($commandRows.Count) command, $($aliasRows.Count) alias, and $($functionRows.Count) function mappings."
