[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $PackageData,
    [Parameter(Mandatory)] [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$expectedPathCount = 271
$expectedPs1Count = 269
$packagePattern = '^[A-Z][A-Za-z0-9]*(?:-[A-Z0-9][A-Za-z0-9]*)*$'
$infrastructureDirectories = @(
    '.git', '.github', '.superpowers', 'assets', 'docs', 'evidence', 'standards', 'tests', 'tools'
)

function ConvertTo-RepositoryPath {
    param(
        [Parameter(Mandatory)] [string] $RepositoryRoot,
        [Parameter(Mandatory)] [string] $FullName
    )

    return $FullName.Substring($RepositoryRoot.Length).TrimStart('\', '/').Replace('\', '/')
}

function Get-OrdinalSortedStrings {
    param([Parameter(Mandatory)] [string[]] $Values)

    $sorted = [string[]] @($Values)
    [System.Array]::Sort($sorted, [System.StringComparer]::Ordinal)
    return $sorted
}

function Add-PathMapProperty {
    param(
        [Parameter(Mandatory)] [System.Collections.Generic.List[string]] $Lines,
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Value
    )

    $line = "            $Name = '$Value'"
    if ($line.Length -le 120) {
        $Lines.Add($line)
        return
    }

    $Lines.Add("            $Name =")
    $Lines.Add("            '$Value'")
}

function Add-PathRow {
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]] $Rows,
        [Parameter(Mandatory)] [AllowEmptyCollection()]
        [System.Collections.Generic.HashSet[string]] $Destinations,
        [Parameter(Mandatory)] [string] $BasePath,
        [Parameter(Mandatory)] [string] $DestinationPackage,
        [Parameter(Mandatory)] [ValidateSet('Detection', 'Remediation')] [string] $Role
    )

    if ($DestinationPackage -cnotmatch $packagePattern) {
        throw "Destination package '$DestinationPackage' does not match the foundation package standard."
    }

    $rolePrefix = if ($Role -eq 'Detection') { 'Detect' } else { 'Remediate' }
    $newPath = "$DestinationPackage/$rolePrefix-$DestinationPackage.ps1"
    if (-not $Destinations.Add($newPath)) {
        throw "Destination collision detected for '$newPath'."
    }

    $Rows.Add([pscustomobject][ordered]@{
            BasePath = $BasePath
            NewPath = $newPath
        })
}

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$data = Import-PowerShellDataFile -Path $PackageData
foreach ($requiredKey in 'PackageRenames', 'SplitPackages', 'AliasMappings', 'FunctionMappings') {
    if (-not $data.ContainsKey($requiredKey)) {
        throw "Package data is missing '$requiredKey'."
    }
}

$packageRenames = [System.Collections.Generic.Dictionary[string, string]]::new(
    [System.StringComparer]::Ordinal
)
$packageRenameKeysIgnoreCase = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
$destinationPackages = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
foreach ($entry in $data.PackageRenames.GetEnumerator()) {
    $sourcePackage = [string] $entry.Key
    $destinationPackage = [string] $entry.Value
    if ([string]::IsNullOrWhiteSpace($sourcePackage) -or [string]::IsNullOrWhiteSpace($destinationPackage)) {
        throw 'Package rename entries require non-empty source and destination package names.'
    }
    if (-not $packageRenameKeysIgnoreCase.Add($sourcePackage)) {
        throw "Package rename source '$sourcePackage' is duplicated or case-colliding."
    }
    if ($destinationPackage -cnotmatch $packagePattern) {
        throw "Destination package '$destinationPackage' does not match the foundation package standard."
    }
    if (-not $destinationPackages.Add($destinationPackage)) {
        throw "Destination package '$destinationPackage' is duplicated or case-colliding."
    }
    $packageRenames.Add($sourcePackage, $destinationPackage)
}

$candidates = [System.Collections.Generic.Dictionary[string, object]]::new(
    [System.StringComparer]::Ordinal
)
$candidatePathsIgnoreCase = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
$ps1Count = 0
$extensionlessPaths = New-Object 'System.Collections.Generic.List[string]'
foreach ($directory in Get-ChildItem -LiteralPath $repositoryRoot -Directory) {
    if ($directory.Name -in $infrastructureDirectories) {
        continue
    }

    foreach ($file in Get-ChildItem -LiteralPath $directory.FullName -Recurse -File) {
        if ($file.Extension -ine '.ps1' -and -not [string]::IsNullOrEmpty($file.Extension)) {
            continue
        }

        $relativePath = ConvertTo-RepositoryPath -RepositoryRoot $repositoryRoot -FullName $file.FullName
        if (-not $candidatePathsIgnoreCase.Add($relativePath)) {
            throw "Runtime candidate '$relativePath' is duplicated or case-colliding."
        }
        $candidates.Add($relativePath, $file)
        if ($file.Extension -ieq '.ps1') {
            $ps1Count++
        }
        else {
            $extensionlessPaths.Add($relativePath)
        }
    }
}

if ($ps1Count -ne $expectedPs1Count) {
    throw "Expected $expectedPs1Count .ps1 runtime candidates; found $ps1Count."
}
$expectedExtensionless = [string[]] @(
    '0 - Template/Detect-Silverlight'
    '0 - Template/Remediate_Silverlight'
)
$actualExtensionless = Get-OrdinalSortedStrings -Values $extensionlessPaths.ToArray()
if ($actualExtensionless.Count -ne $expectedExtensionless.Count) {
    throw "Expected exactly two named extensionless runtime candidates; found $($actualExtensionless.Count)."
}
for ($index = 0; $index -lt $expectedExtensionless.Count; $index++) {
    if ($actualExtensionless[$index] -cne $expectedExtensionless[$index]) {
        throw "Unexpected extensionless runtime candidate '$($actualExtensionless[$index])'."
    }
}
if ($candidates.Count -ne $expectedPathCount) {
    throw "Expected $expectedPathCount runtime candidates; found $($candidates.Count)."
}

$rows = New-Object 'System.Collections.Generic.List[object]'
$classified = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$destinations = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$splitSourcePackages = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($split in @($data.SplitPackages)) {
    $sourcePackage = [string] $split.SourcePackage
    $destinationPackage = [string] $split.DestinationPackage
    if ([string]::IsNullOrWhiteSpace($sourcePackage) -or [string]::IsNullOrWhiteSpace($destinationPackage)) {
        throw 'Split package entries require source and destination package names.'
    }
    if ($packageRenames.ContainsKey($sourcePackage)) {
        throw "Split source package '$sourcePackage' must not also have an ordinary package mapping."
    }
    $null = $splitSourcePackages.Add($sourcePackage)

    foreach ($roleDefinition in @(
            @{ Role = 'Detection'; FileName = [string] $split.Detection }
            @{ Role = 'Remediation'; FileName = [string] $split.Remediation }
        )) {
        $fileName = $roleDefinition.FileName
        if ([string]::IsNullOrWhiteSpace($fileName) -or
            $fileName -ne [System.IO.Path]::GetFileName($fileName)) {
            throw "Split package '$sourcePackage' has an invalid $($roleDefinition.Role) filename."
        }

        $basePath = "$sourcePackage/$fileName"
        if (-not $candidates.ContainsKey($basePath)) {
            throw "Split source '$basePath' does not exist in the runtime inventory."
        }
        if (-not $classified.Add($basePath)) {
            throw "Runtime candidate '$basePath' is classified more than once."
        }
        Add-PathRow `
            -Rows $rows `
            -Destinations $destinations `
            -BasePath $basePath `
            -DestinationPackage $destinationPackage `
            -Role $roleDefinition.Role
    }
}

$ordinaryRoles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$usedPackageRenames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($basePath in Get-OrdinalSortedStrings -Values ([string[]] $candidates.Keys)) {
    if ($classified.Contains($basePath)) {
        continue
    }

    $separatorIndex = $basePath.IndexOf('/')
    if ($separatorIndex -lt 1) {
        throw "Runtime candidate '$basePath' is not inside a package directory."
    }
    $sourcePackage = $basePath.Substring(0, $separatorIndex)
    if ($splitSourcePackages.Contains($sourcePackage)) {
        throw "Split package '$sourcePackage' contains unclassified runtime candidate '$basePath'."
    }
    if (-not $packageRenames.ContainsKey($sourcePackage)) {
        throw "Runtime package '$sourcePackage' has no explicit package mapping."
    }

    $fileName = $basePath.Substring($separatorIndex + 1)
    $role = $null
    if ($basePath -ceq 'Detect-Browser-Passwords/Detect-Browser-Passwords.ps1') {
        $role = 'Detection'
    }
    elseif ($fileName -imatch '^detection(?:[_-]|$)') {
        $role = 'Detection'
    }
    elseif ($fileName -imatch '^remediation(?:[_-]|$)') {
        $role = 'Remediation'
    }
    if ($null -eq $role) {
        throw "Runtime candidate '$basePath' has no recognized role."
    }

    $roleKey = "$sourcePackage`0$role"
    if (-not $ordinaryRoles.Add($roleKey)) {
        throw "Unsplit package '$sourcePackage' contains duplicate $role roles."
    }
    $null = $usedPackageRenames.Add($sourcePackage)
    $null = $classified.Add($basePath)
    Add-PathRow `
        -Rows $rows `
        -Destinations $destinations `
        -BasePath $basePath `
        -DestinationPackage $packageRenames[$sourcePackage] `
        -Role $role
}

foreach ($sourcePackage in $packageRenames.Keys) {
    if (-not $usedPackageRenames.Contains($sourcePackage)) {
        throw "Package mapping '$sourcePackage' does not match a runtime package."
    }
}
if (
    $classified.Count -ne $candidates.Count -or
    $rows.Count -ne $expectedPathCount
) {
    throw (
        'Path generation classified {0} candidates and produced {1} rows; expected {2}.' -f
        $classified.Count,
        $rows.Count,
        $expectedPathCount
    )
}

$rowComparison = [System.Comparison[object]] {
    param($left, $right)

    $comparison = [System.StringComparer]::Ordinal.Compare(
        [string] $left.NewPath,
        [string] $right.NewPath
    )
    if ($comparison -ne 0) {
        return $comparison
    }
    return [System.StringComparer]::Ordinal.Compare(
        [string] $left.BasePath,
        [string] $right.BasePath
    )
}
$rows.Sort($rowComparison)

$lines = New-Object 'System.Collections.Generic.List[string]'
$lines.Add('@{')
$lines.Add('    Paths = @(')
foreach ($row in $rows) {
    $basePath = ([string] $row.BasePath).Replace("'", "''")
    $newPath = ([string] $row.NewPath).Replace("'", "''")
    $lines.Add('        @{')
    Add-PathMapProperty -Lines $lines -Name 'BasePath' -Value $basePath
    Add-PathMapProperty -Lines $lines -Name 'NewPath' -Value $newPath
    $lines.Add('        }')
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
Write-Output "Generated $($rows.Count) foundation path mappings."
