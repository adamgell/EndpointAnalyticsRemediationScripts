[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $PathMap
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Git {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRoot,

        [Parameter(Mandatory)]
        [string[]] $Arguments
    )

    $output = @(& git -C $RepositoryRoot @Arguments 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed: $($output -join [Environment]::NewLine)"
    }

    return $output
}

$repositoryRootOutput = @(& git rev-parse --show-toplevel 2>&1)
if ($LASTEXITCODE -ne 0 -or $repositoryRootOutput.Count -ne 1) {
    throw "Unable to resolve the Git repository root: $($repositoryRootOutput -join [Environment]::NewLine)"
}
$repositoryRoot = [System.IO.Path]::GetFullPath([string] $repositoryRootOutput[0])

$approvedPathMap = [System.IO.Path]::GetFullPath(
    (Join-Path $repositoryRoot 'evidence/foundation/PathMap.psd1')
)
$requestedPathMap = [System.IO.Path]::GetFullPath(
    (Join-Path ([string] (Get-Location)) $PathMap)
)
if (-not [string]::Equals(
        $requestedPathMap,
        $approvedPathMap,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
    throw "PathMap must resolve to the approved map: $approvedPathMap"
}
if (-not (Test-Path -LiteralPath $approvedPathMap -PathType Leaf)) {
    throw "Approved path map does not exist: $approvedPathMap"
}

$map = Import-PowerShellDataFile -LiteralPath $approvedPathMap
$paths = @($map.Paths)
if ($paths.Count -ne 271) {
    throw "Approved path map must contain exactly 271 rows; found $($paths.Count)."
}

$sourcePaths = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
$destinationPaths = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
$exactMappedSourcePaths = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
$sourceHashes = @{}
$trackedPaths = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
foreach ($trackedPath in Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @('ls-files', '--cached')) {
    [void] $trackedPaths.Add([string] $trackedPath)
}

$repositoryPrefix = $repositoryRoot.TrimEnd(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar
) + [System.IO.Path]::DirectorySeparatorChar
foreach ($entry in $paths) {
    $sourceRelativePath = [string] $entry.BasePath
    $destinationRelativePath = [string] $entry.NewPath
    if ([string]::IsNullOrWhiteSpace($sourceRelativePath) -or
        [string]::IsNullOrWhiteSpace($destinationRelativePath)) {
        throw 'Every path-map row must define non-empty BasePath and NewPath values.'
    }
    if ([System.IO.Path]::IsPathRooted($sourceRelativePath) -or
        [System.IO.Path]::IsPathRooted($destinationRelativePath)) {
        throw "Path-map rows must use repository-relative paths: $sourceRelativePath -> $destinationRelativePath"
    }

    $sourcePath = [System.IO.Path]::GetFullPath(
        (Join-Path $repositoryRoot $sourceRelativePath)
    )
    $destinationPath = [System.IO.Path]::GetFullPath(
        (Join-Path $repositoryRoot $destinationRelativePath)
    )
    if (-not $sourcePath.StartsWith(
            $repositoryPrefix,
            [System.StringComparison]::OrdinalIgnoreCase
        ) -or
        -not $destinationPath.StartsWith(
            $repositoryPrefix,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
        throw "Path-map row escapes the repository root: $sourceRelativePath -> $destinationRelativePath"
    }
    if (-not $sourcePaths.Add($sourceRelativePath)) {
        throw "Duplicate source path in approved map: $sourceRelativePath"
    }
    [void] $exactMappedSourcePaths.Add($sourceRelativePath)
    if (-not $destinationPaths.Add($destinationRelativePath)) {
        throw "Duplicate destination path in approved map: $destinationRelativePath"
    }
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        throw "Mapped source does not exist: $sourceRelativePath"
    }
    if (Test-Path -LiteralPath $destinationPath) {
        throw "Mapped destination already exists: $destinationRelativePath"
    }

    $sourceHashes[$sourceRelativePath] = (
        Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256
    ).Hash
}

$allowedDirtyPaths = @(
    'tests/Repository.Tests.ps1'
    'tools/Invoke-FoundationMove.ps1'
)
$modifiedOrStagedPaths = @(
    Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @('diff', '--name-only', '--')
    Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @('diff', '--cached', '--name-only', '--')
) | Where-Object { $_ } | Sort-Object -Unique
$untrackedPaths = @(
    Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @(
        'ls-files', '--others', '--exclude-standard'
    )
) | Where-Object { $_ } | Sort-Object -Unique
$unexpectedDirtyPaths = @(@(
        $modifiedOrStagedPaths | Where-Object { $_ -cnotin $allowedDirtyPaths }
        $untrackedPaths | Where-Object {
            $_ -cnotin $allowedDirtyPaths -and
                -not $exactMappedSourcePaths.Contains([string] $_)
        }
    ) | Sort-Object -Unique)
if ($unexpectedDirtyPaths.Count -ne 0) {
    throw "Working tree contains changes outside the Task 6 foundation files: $($unexpectedDirtyPaths -join ', ')"
}

$destinationDirectories = @($paths | ForEach-Object {
        Split-Path -Parent ([string] $_.NewPath)
    } | Sort-Object -Unique)
foreach ($destinationDirectory in $destinationDirectories) {
    $destinationDirectoryPath = Join-Path $repositoryRoot $destinationDirectory
    if (-not (Test-Path -LiteralPath $destinationDirectoryPath -PathType Container)) {
        [void] (New-Item -ItemType Directory -Path $destinationDirectoryPath -Force)
    }
}

$movedCount = 0
foreach ($entry in $paths) {
    $sourceRelativePath = [string] $entry.BasePath
    $destinationRelativePath = [string] $entry.NewPath
    $sourcePath = Join-Path $repositoryRoot $sourceRelativePath
    $destinationPath = Join-Path $repositoryRoot $destinationRelativePath

    if ($trackedPaths.Contains($sourceRelativePath)) {
        [void] (Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @(
                'mv', '--', $sourceRelativePath, $destinationRelativePath
            ))
    }
    else {
        Move-Item -LiteralPath $sourcePath -Destination $destinationPath
    }

    $destinationHash = (Get-FileHash -LiteralPath $destinationPath -Algorithm SHA256).Hash
    if ($destinationHash -cne $sourceHashes[$sourceRelativePath]) {
        throw "Byte hash changed while moving $sourceRelativePath to $destinationRelativePath."
    }
    $movedCount++
}

foreach ($destinationDirectory in $destinationDirectories) {
    $destinationDirectoryPath = Join-Path $repositoryRoot $destinationDirectory
    $actualDirectory = Get-Item -LiteralPath $destinationDirectoryPath
    $actualRelativePath = $actualDirectory.FullName.
        Substring($repositoryRoot.Length).
        TrimStart('\', '/').
        Replace('\', '/')
    if ([string]::Equals(
            $actualRelativePath,
            $destinationDirectory,
            [System.StringComparison]::Ordinal
        )) {
        continue
    }
    if (-not [string]::Equals(
            $actualRelativePath,
            $destinationDirectory,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
        throw "Destination directory resolved unexpectedly: $actualRelativePath"
    }

    $expectedFileNames = @($paths | Where-Object {
            (Split-Path -Parent ([string] $_.NewPath)) -ceq $destinationDirectory
        } | ForEach-Object {
            Split-Path -Leaf ([string] $_.NewPath)
        })
    $unexpectedItems = @(Get-ChildItem -LiteralPath $actualDirectory.FullName -Force |
        Where-Object { $_.PSIsContainer -or $_.Name -cnotin $expectedFileNames })
    if ($unexpectedItems.Count -ne 0) {
        throw "Cannot normalize destination directory casing because it contains unmapped items: $actualRelativePath"
    }

    $temporaryDirectoryPath = Join-Path $repositoryRoot (
        '.foundation-case-' + [guid]::NewGuid().ToString('N')
    )
    Move-Item -LiteralPath $actualDirectory.FullName -Destination $temporaryDirectoryPath
    Move-Item -LiteralPath $temporaryDirectoryPath -Destination $destinationDirectoryPath
}

$sourceDirectories = @($paths | ForEach-Object {
        Split-Path -Parent ([string] $_.BasePath)
    } | Sort-Object -Unique | Sort-Object { $_.Length } -Descending)
foreach ($sourceDirectory in $sourceDirectories) {
    $sourceDirectoryPath = Join-Path $repositoryRoot $sourceDirectory
    if ((Test-Path -LiteralPath $sourceDirectoryPath -PathType Container) -and
        @(Get-ChildItem -LiteralPath $sourceDirectoryPath -Force).Count -eq 0) {
        Remove-Item -LiteralPath $sourceDirectoryPath -Force
    }
}

if ($movedCount -ne 271) {
    throw "Expected to move 271 scripts; moved $movedCount."
}

Write-Output "Moved $movedCount foundation scripts with byte-identical content."
