Describe 'Foundation path map' -Tag 'FoundationMapCurrentTree' {
    BeforeAll {
        $map = Import-PowerShellDataFile "$PSScriptRoot/../evidence/foundation/PathMap.psd1"
    }

    It 'maps all 271 baseline runtime candidates exactly once' {
        @($map.Paths).Count | Should -Be 271
        @($map.Paths.BasePath | Sort-Object -Unique).Count | Should -Be 271
        @($map.Paths.NewPath | Sort-Object -Unique).Count | Should -Be 271
    }

    It 'maps every destination to a ps1 file with a standard basename' {
        $invalid = $map.Paths.NewPath | Where-Object {
            $_ -notmatch '/(Detect|Remediate)-[A-Z][A-Za-z0-9]*(?:-[A-Z0-9][A-Za-z0-9]*)*\.ps1$'
        }
        $invalid | Should -BeNullOrEmpty
    }
}

Describe 'Foundation path map details' -Tag 'FoundationMapCurrentTree' {
    BeforeAll {
        $map = Import-PowerShellDataFile "$PSScriptRoot/../evidence/foundation/PathMap.psd1"
    }

    It 'maps both named extensionless scripts to ps1 destinations' {
        ($map.Paths | Where-Object BasePath -CEQ '0 - Template/Detect-Silverlight').NewPath |
            Should -Be 'Remove-Silverlight/Detect-Remove-Silverlight.ps1'
        ($map.Paths | Where-Object BasePath -CEQ '0 - Template/Remediate_Silverlight').NewPath |
            Should -Be 'Remove-Silverlight/Remediate-Remove-Silverlight.ps1'
    }

    It 'covers the exact non-executing runtime inventory' {
        $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $scriptRoot = Join-Path $repositoryRoot 'scripts'
        $inventory = @(
            foreach ($directory in Get-ChildItem -LiteralPath $scriptRoot -Directory) {
                foreach ($file in Get-ChildItem -LiteralPath $directory.FullName -Recurse -File) {
                    if ($file.Extension -ine '.ps1' -and -not [string]::IsNullOrEmpty($file.Extension)) {
                        continue
                    }
                    $file.FullName.Substring($scriptRoot.Length).TrimStart('\', '/').Replace('\', '/')
                }
            }
        )


        @($inventory).Count | Should -Be 271
        Compare-Object -ReferenceObject @($map.Paths.NewPath) -DifferenceObject $inventory -CaseSensitive |
            Should -BeNullOrEmpty
    }

    It 'orders destinations with the ordinal comparer' {
        [string[]] $actual = @($map.Paths.NewPath)
        [string[]] $expected = @($actual)
        [System.Array]::Sort($expected, [System.StringComparer]::Ordinal)

        ($actual -join "`n") | Should -Be ($expected -join "`n")
    }
}

Describe 'Foundation symbol map' -Tag 'FoundationMapCurrentTree' {
    BeforeAll {
        $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $symbolMapPath = Join-Path $repositoryRoot 'evidence/foundation/SymbolRenames.psd1'
        $symbolMap = Import-PowerShellDataFile $symbolMapPath
    }

    It 'records every canonical cmdlet-casing rewrite' {
        @($symbolMap.Commands).Count | Should -Be 81
        $invalid = @($symbolMap.Commands | Where-Object {
                $_.OldName -ceq $_.NewName -or
                $_.OldName -ine $_.NewName -or
                [int] $_.Occurrence -lt 1
            })
        $invalid | Should -BeNullOrEmpty
    }

    It 'records the 12 reviewed alias occurrences across 9 files' {
        $expected = @(
            'Check-DiskHealth/Detect-Check-DiskHealth.ps1|?|Where-Object|1'
            'Clear-TeamsCache/Remediate-Clear-TeamsCache.ps1|echo|Write-Output|1'
            'Clear-TeamsCache/Remediate-Clear-TeamsCache.ps1|echo|Write-Output|2'
            'Device-Auto-Syncer/Remediate-Device-Auto-Syncer.ps1|?|Where-Object|1'
            'Get-CleanUpDisk/Detect-Get-CleanUpDisk.ps1|Where|Where-Object|1'
            'Get-ConnectedDevices/Detect-Get-ConnectedDevices.ps1|%|ForEach-Object|1'
            'Remove-ConsumerApps/Detect-Remove-ConsumerApps.ps1|Where|Where-Object|1'
            'Remove-ConsumerApps/Remediate-Remove-ConsumerApps.ps1|Where|Where-Object|1'
            'Remove-ConsumerApps/Remediate-Remove-ConsumerApps.ps1|Where|Where-Object|2'
            'Run-Browser/Remediate-Run-Browser.ps1|Start|Start-Process|1'
            'Toast-RebootMessage/Remediate-Toast-RebootMessage.ps1|where|Where-Object|1'
            'Toast-RebootMessage/Remediate-Toast-RebootMessage.ps1|where|Where-Object|2'
        )
        $actual = @($symbolMap.Aliases | ForEach-Object {
                '{0}|{1}|{2}|{3}' -f $_.Path, $_.OldName, $_.NewName, $_.Occurrence
            })

        @($actual).Count | Should -Be 12
        @($symbolMap.Aliases.Path | Sort-Object -Unique).Count | Should -Be 9
        Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive |
            Should -BeNullOrEmpty
    }

    It 'preserves both lowercase Toast aliases with source-exact casing' {
        $actual = @($symbolMap.Aliases | Where-Object {
                $_.Path -ceq 'Toast-RebootMessage/Remediate-Toast-RebootMessage.ps1'
            } | ForEach-Object {
                '{0}|{1}' -f $_.OldName, $_.Occurrence
            })

        ($actual -join "`n") | Should -BeExactly "where|1`nwhere|2"
    }

    It 'records the five reviewed function definitions' {
        $expected = @(
            'Enable-RDP/Detect-Enable-RDP.ps1|IsMember|Test-GroupMembership'
            'Enable-RDP/Remediate-Enable-RDP.ps1|IsMember|Test-GroupMembership'
            (
                'Get-Device-Uptime-And-Reboot/Remediate-Get-Device-Uptime-And-Reboot.ps1|' +
                'Display-ToastNotification|Show-ToastNotification'
            )
            'Make-Speedtest/Remediate-Make-Speedtest.ps1|Build-Signature|New-LogAnalyticsSignature'
            'Make-Speedtest/Remediate-Make-Speedtest.ps1|Post-LogAnalyticsData|Send-LogAnalyticsData'
        )
        $actual = @($symbolMap.Functions | ForEach-Object {
                '{0}|{1}|{2}' -f $_.Path, $_.OldName, $_.NewName
            })

        @($actual).Count | Should -Be 5
        Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive |
            Should -BeNullOrEmpty
    }

    It 'uses deterministic ordinal path and occurrence ordering' {
        foreach ($name in 'Commands', 'Aliases') {
            [string[]] $actual = @($symbolMap[$name] | ForEach-Object {
                    '{0}`0{1:D8}`0{2}`0{3}' -f $_.Path, [int] $_.Occurrence, $_.OldName, $_.NewName
                })
            [string[]] $expected = @($actual)
            [System.Array]::Sort($expected, [System.StringComparer]::Ordinal)
            ($actual -join "`n") | Should -Be ($expected -join "`n")
        }

        [string[]] $actualFunctions = @($symbolMap.Functions | ForEach-Object {
                '{0}`0{1}`0{2}' -f $_.Path, $_.OldName, $_.NewName
            })
        [string[]] $expectedFunctions = @($actualFunctions)
        [System.Array]::Sort($expectedFunctions, [System.StringComparer]::Ordinal)
        ($actualFunctions -join "`n") | Should -Be ($expectedFunctions -join "`n")
    }
}

Describe 'Foundation symbol map baseline' -Tag 'FoundationMapBaseline' {
    BeforeAll {
        $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $symbolGenerator = Join-Path $repositoryRoot 'tools/New-FoundationSymbolMap.ps1'
        $pathMapPath = Join-Path $repositoryRoot 'evidence/foundation/PathMap.psd1'
        $baseRevisionPath = Join-Path $repositoryRoot 'evidence/foundation/BaseRevision.txt'
        $pathMap = Import-PowerShellDataFile $pathMapPath
        $packageDataPath = Join-Path $repositoryRoot 'standards/FoundationPackages.psd1'
        $symbolMapPath = Join-Path $repositoryRoot 'evidence/foundation/SymbolRenames.psd1'
        $expectedSymbolMapBytes = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($symbolMapPath))
        $symbolMap = Import-PowerShellDataFile $symbolMapPath
        $baseRevision = (
            Get-Content "$repositoryRoot/evidence/foundation/BaseRevision.txt" -Raw
        ).Trim()
        Import-Module "$repositoryRoot/tools/RepositoryCatalog.psm1" -Force
        $gitContext = Resolve-FoundationRepositoryGitContext -RepositoryRoot $repositoryRoot
        $commonGitDirectoryOutput = @(
            & git `
                "--git-dir=$($gitContext.GitDirectory)" `
                rev-parse `
                --git-common-dir 2>&1
        )
        if ($LASTEXITCODE -ne 0 -or $commonGitDirectoryOutput.Count -ne 1) {
            throw 'Unable to resolve the common Git directory for symbol-map fixtures.'
        }
        $commonGitDirectoryValue = ([string] $commonGitDirectoryOutput[0]).Trim()
        $commonGitDirectory = if ([System.IO.Path]::IsPathRooted($commonGitDirectoryValue)) {
            [System.IO.Path]::GetFullPath($commonGitDirectoryValue)
        }
        else {
            [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $commonGitDirectoryValue))
        }

        function Invoke-FoundationSymbolFixtureGit {
            param(
                [Parameter(Mandatory)] [string[]] $Arguments,
                [string] $IndexPath
            )

            $originalGitDirectory = $env:GIT_DIR
            $originalGitWorkTree = $env:GIT_WORK_TREE
            $originalGitIndexFile = $env:GIT_INDEX_FILE
            $originalGitNoReplaceObjects = $env:GIT_NO_REPLACE_OBJECTS
            try {
                $env:GIT_DIR = $null
                $env:GIT_WORK_TREE = $null
                $env:GIT_INDEX_FILE = $IndexPath
                $env:GIT_NO_REPLACE_OBJECTS = $null
                $output = @(& git @Arguments 2>&1)
                $exitCode = $LASTEXITCODE
            }
            finally {
                $env:GIT_DIR = $originalGitDirectory
                $env:GIT_WORK_TREE = $originalGitWorkTree
                $env:GIT_INDEX_FILE = $originalGitIndexFile
                $env:GIT_NO_REPLACE_OBJECTS = $originalGitNoReplaceObjects
            }
            if ($exitCode -ne 0) {
                throw "git $($Arguments -join ' ') failed: $($output -join [Environment]::NewLine)"
            }

            return $output
        }

        function New-FoundationSymbolGitFixture {
            param(
                [Parameter(Mandatory)] [string] $Root,
                [Parameter(Mandatory)] [string] $ScriptContent,
                [string] $MappedBasePath
            )

            [System.IO.Directory]::CreateDirectory($Root) | Out-Null
            $gitDirectory = Join-Path $Root 'repository.git'
            $null = Invoke-FoundationSymbolFixtureGit -Arguments @(
                'init'
                '--bare'
                '--quiet'
                $gitDirectory
            )
            $alternateDirectory = Join-Path $gitDirectory 'objects/info'
            [System.IO.Directory]::CreateDirectory($alternateDirectory) | Out-Null
            $alternateObjects = (Join-Path $commonGitDirectory 'objects').Replace('\', '/')
            [System.IO.File]::WriteAllText(
                (Join-Path $alternateDirectory 'alternates'),
                $alternateObjects,
                (New-Object System.Text.UTF8Encoding($false))
            )

            $scriptPath = Join-Path $Root 'Sentinel.ps1'
            [System.IO.File]::WriteAllText(
                $scriptPath,
                $ScriptContent,
                (New-Object System.Text.UTF8Encoding($false))
            )
            $blob = @(
                Invoke-FoundationSymbolFixtureGit -Arguments @(
                    "--git-dir=$gitDirectory"
                    'hash-object'
                    '-w'
                    $scriptPath
                )
            )[0]
            $indexPath = Join-Path $Root 'fixture.index'
            $readTreeArguments = @(
                "--git-dir=$gitDirectory"
                'read-tree'
                $baseRevision
            )
            $null = Invoke-FoundationSymbolFixtureGit `
                -IndexPath $indexPath `
                -Arguments $readTreeArguments
            $firstPath = @($pathMap.Paths)[0]
            $mappedPath = if ([string]::IsNullOrWhiteSpace($MappedBasePath)) {
                [string] $firstPath.BasePath
            }
            else {
                $MappedBasePath
            }
            $updateIndexArguments = @(
                "--git-dir=$gitDirectory"
                'update-index'
                '--add'
                '--cacheinfo'
                '100644'
                ([string] $blob)
                $mappedPath
            )
            $null = Invoke-FoundationSymbolFixtureGit `
                -IndexPath $indexPath `
                -Arguments $updateIndexArguments

            $writeTreeArguments = @(
                "--git-dir=$gitDirectory"
                'write-tree'
            )
            $treeOutput = Invoke-FoundationSymbolFixtureGit `
                -IndexPath $indexPath `
                -Arguments $writeTreeArguments
            $tree = @($treeOutput)[0]
            $revision = @(
                Invoke-FoundationSymbolFixtureGit -Arguments @(
                    "--git-dir=$gitDirectory"
                    '-c'
                    'user.name=Foundation Symbol Tests'
                    '-c'
                    'user.email=foundation-symbol@example.invalid'
                    'commit-tree'
                    ([string] $tree)
                    '-p'
                    $baseRevision
                    '-m'
                    'foundation symbol fixture'
                )
            )[0]
            $markerPath = Join-Path $Root 'BaseRevision.txt'
            [System.IO.File]::WriteAllText(
                $markerPath,
                ([string] $revision),
                [System.Text.Encoding]::ASCII
            )

            return [pscustomobject]@{
                GitDirectory = $gitDirectory
                MarkerPath = $markerPath
                Revision = [string] $revision
            }
        }

        function Invoke-FoundationSymbolFixtureGenerator {
            param(
                [Parameter(Mandatory)] $Fixture,
                [Parameter(Mandatory)] [string] $MarkerPath,
                [Parameter(Mandatory)] [string] $OutputPath
            )

            $originalGitDirectory = $env:GIT_DIR
            $originalGitWorkTree = $env:GIT_WORK_TREE
            $originalGitNoReplaceObjects = $env:GIT_NO_REPLACE_OBJECTS
            try {
                $env:GIT_DIR = [string] $Fixture.GitDirectory
                $env:GIT_WORK_TREE = $repositoryRoot
                $env:GIT_NO_REPLACE_OBJECTS = $null
                & $symbolGenerator `
                    -PathMap $pathMapPath `
                    -PackageData $packageDataPath `
                    -OutputPath $OutputPath `
                    -BaseRevisionPath $MarkerPath
            }
            finally {
                $env:GIT_DIR = $originalGitDirectory
                $env:GIT_WORK_TREE = $originalGitWorkTree
                $env:GIT_NO_REPLACE_OBJECTS = $originalGitNoReplaceObjects
            }
        }
    }

    It 'regenerates byte-identically from the default baseline marker in the normalized tree' {
        $outputPath = Join-Path $TestDrive 'current-tree-SymbolRenames.psd1'

        & $symbolGenerator `
            -PathMap $pathMapPath `
            -PackageData $packageDataPath `
            -OutputPath $outputPath

        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputPath)) |
            Should -BeExactly $expectedSymbolMapBytes
    }

    It 'rejects a baseline marker that is not exactly one full Git SHA' {
        $invalidMarkerPath = Join-Path $TestDrive 'InvalidBaseRevision.txt'
        [System.IO.File]::WriteAllText(
            $invalidMarkerPath,
            "$baseRevision`n",
            (New-Object System.Text.UTF8Encoding($false))
        )

        {
            & $symbolGenerator `
                -PathMap $pathMapPath `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $TestDrive 'invalid-marker-SymbolRenames.psd1') `
                -BaseRevisionPath $invalidMarkerPath
        } | Should -Throw '*Baseline marker must contain exactly one lowercase 40-character Git commit SHA*'
    }

    It 'rejects a full baseline revision that does not exist' {
        $missingRevision = '0000000000000000000000000000000000000000'
        $missingRevisionPath = Join-Path $TestDrive 'MissingBaseRevision.txt'
        [System.IO.File]::WriteAllText(
            $missingRevisionPath,
            $missingRevision,
            (New-Object System.Text.UTF8Encoding($false))
        )

        {
            & $symbolGenerator `
                -PathMap $pathMapPath `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $TestDrive 'missing-revision-SymbolRenames.psd1') `
                -BaseRevisionPath $missingRevisionPath
        } | Should -Throw "*Baseline revision '$missingRevision' does not exist or is not a commit.*"
    }

    It 'rejects a mapped legacy source missing from the baseline revision' {
        $missingBasePath = 'Missing-Foundation-Baseline/Detect-Missing-Foundation-Baseline.ps1'
        $missingBlobPathMap = Join-Path $TestDrive 'MissingBlobPathMap.psd1'
        $firstPath = @($pathMap.Paths)[0]
        $pathMapContent = [System.IO.File]::ReadAllText($pathMapPath)
        $originalBasePathLine = "            BasePath = '$($firstPath.BasePath)'"
        $missingBasePathLine = "            BasePath = '$missingBasePath'"
        [System.IO.File]::WriteAllText(
            $missingBlobPathMap,
            $pathMapContent.Replace($originalBasePathLine, $missingBasePathLine),
            (New-Object System.Text.UTF8Encoding($false))
        )

        {
            & $symbolGenerator `
                -PathMap $missingBlobPathMap `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $TestDrive 'missing-blob-SymbolRenames.psd1') `
                -BaseRevisionPath $baseRevisionPath
        } | Should -Throw "*Baseline blob '$baseRevision`:$missingBasePath' does not exist.*"
    }

    It 'never executes a baseline catalog sentinel' {
        $sideEffectPath = Join-Path $TestDrive 'baseline-catalog-sentinel-executed.txt'
        $sentinelContent = (
            "[System.IO.File]::WriteAllText('{0}', 'executed')" -f
            $sideEffectPath.Replace("'", "''")
        )
        $fixture = New-FoundationSymbolGitFixture `
            -Root (Join-Path $TestDrive 'baseline-catalog-sentinel') `
            -ScriptContent $sentinelContent
        $outputPath = Join-Path $TestDrive 'baseline-sentinel-SymbolRenames.psd1'

        Invoke-FoundationSymbolFixtureGenerator `
            -Fixture $fixture `
            -MarkerPath $fixture.MarkerPath `
            -OutputPath $outputPath

        [System.IO.File]::Exists($sideEffectPath) | Should -BeFalse
        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputPath)) |
            Should -BeExactly $expectedSymbolMapBytes
    }

    It 'rejects a stale function name composed in a dynamic invocation target' {
        $scriptContent = @'
function IsMember {
    param([string] $Group)
    return $Group -eq 'Administrators'
}
IsMember -Group 'Administrators'
& ('Is' + 'Member') -Group 'Administrators'
'@
        $fixture = New-FoundationSymbolGitFixture `
            -Root (Join-Path $TestDrive 'composed-dynamic-function') `
            -ScriptContent $scriptContent `
            -MappedBasePath 'Enable-RDP/detection_Enable-RDPDetection.ps1'
        $outputPath = Join-Path $TestDrive 'composed-dynamic-function-SymbolRenames.psd1'

        {
            Invoke-FoundationSymbolFixtureGenerator `
                -Fixture $fixture `
                -MarkerPath $fixture.MarkerPath `
                -OutputPath $outputPath
        } | Should -Throw (
            "*Function mapping 'Enable-RDP/Detect-Enable-RDP.ps1|IsMember' " +
            "has an ambiguous or non-static reference.*"
        )
    }

    It 'ignores a composed argument nested in a parenthesized command pipeline' {
        $scriptContent = @'
function IsMember {
    param([string] $Group)
    return $Group -eq 'Administrators'
}
IsMember -Group 'Administrators'
& (Write-Output ('Is' + 'Member') 'Get-Date' | Select-Object -Last 1)
'@
        $fixture = New-FoundationSymbolGitFixture `
            -Root (Join-Path $TestDrive 'composed-argument-pipeline') `
            -ScriptContent $scriptContent `
            -MappedBasePath 'Enable-RDP/detection_Enable-RDPDetection.ps1'
        $outputPath = Join-Path $TestDrive 'composed-argument-pipeline-SymbolRenames.psd1'

        Invoke-FoundationSymbolFixtureGenerator `
            -Fixture $fixture `
            -MarkerPath $fixture.MarkerPath `
            -OutputPath $outputPath

        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputPath)) |
            Should -BeExactly $expectedSymbolMapBytes
    }


    It 'ignores repository-local Git replacement objects for the baseline revision' {
        $fixture = New-FoundationSymbolGitFixture `
            -Root (Join-Path $TestDrive 'replacement-object') `
            -ScriptContent "write-output 'replacement object'"
        $null = Invoke-FoundationSymbolFixtureGit -Arguments @(
            "--git-dir=$($fixture.GitDirectory)"
            'update-ref'
            "refs/replace/$baseRevision"
            $fixture.Revision
        )
        $outputPath = Join-Path $TestDrive 'replacement-object-SymbolRenames.psd1'

        Invoke-FoundationSymbolFixtureGenerator `
            -Fixture $fixture `
            -MarkerPath $baseRevisionPath `
            -OutputPath $outputPath

        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputPath)) |
            Should -BeExactly $expectedSymbolMapBytes
    }


    It 'regenerates byte-identically when live command discovery is unavailable' {
        $outputPath = Join-Path $TestDrive 'without-live-discovery-SymbolRenames.psd1'
        & {
            function Get-Command {
                throw 'Live command discovery is unavailable.'
            }
            function Get-Alias {
                throw 'Live alias discovery is unavailable.'
            }

            & $symbolGenerator `
                -PathMap $pathMapPath `
                -PackageData $packageDataPath `
                -OutputPath $outputPath `
                -BaseRevisionPath $baseRevisionPath
        }

        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputPath)) |
            Should -BeExactly $expectedSymbolMapBytes
    }

    It 'regenerates byte-identically when live command discovery is polluted' {
        $outputPath = Join-Path $TestDrive 'with-polluted-live-discovery-SymbolRenames.psd1'
        & {
            function Get-Command {
                [CmdletBinding()]
                param([object] $CommandType)

                [pscustomobject]@{ Name = 'Get-SmbServerConfiguration' }
            }
            function Get-Alias {
                [CmdletBinding()]
                param()

                [pscustomobject]@{
                    Name = 'write-host'
                    ResolvedCommandName = 'Host-Pollution'
                }
            }

            & $symbolGenerator `
                -PathMap $pathMapPath `
                -PackageData $packageDataPath `
                -OutputPath $outputPath `
                -BaseRevisionPath $baseRevisionPath
        }

        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputPath)) |
            Should -BeExactly $expectedSymbolMapBytes
    }

    It 'rejects a path-map row with indistinguishable source and destination paths' {
        $ambiguousPathMap = Join-Path $TestDrive 'AmbiguousPathMap.psd1'
        $firstPath = @($pathMap.Paths)[0]
        $pathMapContent = [System.IO.File]::ReadAllText($pathMapPath)
        $originalRow = @(
            '        @{'
            "            BasePath = '$($firstPath.BasePath)'"
            "            NewPath = '$($firstPath.NewPath)'"
            '        }'
        ) -join "`n"
        $ambiguousRow = @(
            '        @{'
            "            BasePath = '$($firstPath.BasePath)'"
            "            NewPath = '$($firstPath.BasePath)'"
            '        }'
        ) -join "`n"
        [System.IO.File]::WriteAllText(
            $ambiguousPathMap,
            $pathMapContent.Replace($originalRow, $ambiguousRow),
            (New-Object System.Text.UTF8Encoding($false))
        )

        {
            & $symbolGenerator `
                -PathMap $ambiguousPathMap `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $TestDrive 'ambiguous-SymbolRenames.psd1') `
                -BaseRevisionPath $baseRevisionPath
        } | Should -Throw "*Path map row '$($firstPath.BasePath)' uses indistinguishable source and destination paths.*"
    }
    It 'rejects embedded double quotes in either path-map component before reading Git blobs' {
        $firstPath = @($pathMap.Paths)[0]
        $pathMapContent = [System.IO.File]::ReadAllText($pathMapPath)
        $originalRow = @(
            '        @{'
            "            BasePath = '$($firstPath.BasePath)'"
            "            NewPath = '$($firstPath.NewPath)'"
            '        }'
        ) -join "`n"
        $cases = @(
            @{
                Name = 'quoted-source'
                BasePath = 'Activate-Numlock/"source"/detection_Activate-Numlock.ps1'
                NewPath = [string] $firstPath.NewPath
            }
            @{
                Name = 'quoted-destination'
                BasePath = [string] $firstPath.BasePath
                NewPath = 'Activate-Numlock/"destination"/Detect-Activate-Numlock.ps1'
            }
        )

        foreach ($case in $cases) {
            $adversarialPathMap = Join-Path $TestDrive "$($case.Name)-PathMap.psd1"
            $adversarialRow = @(
                '        @{'
                "            BasePath = '$($case.BasePath)'"
                "            NewPath = '$($case.NewPath)'"
                '        }'
            ) -join "`n"
            [System.IO.File]::WriteAllText(
                $adversarialPathMap,
                $pathMapContent.Replace($originalRow, $adversarialRow),
                (New-Object System.Text.UTF8Encoding($false))
            )

            $outputPath = Join-Path $TestDrive "$($case.Name)-SymbolRenames.psd1"
            $exceptionMessage = $null
            try {
                & $symbolGenerator `
                    -PathMap $adversarialPathMap `
                    -PackageData $packageDataPath `
                    -OutputPath $outputPath `
                    -BaseRevisionPath $baseRevisionPath
            }
            catch {
                $exceptionMessage = $_.Exception.Message
            }

            $exceptionMessage | Should -BeExactly (
                "Path map contains unsafe row '$($case.BasePath)' -> '$($case.NewPath)'."
            )
            [System.IO.File]::Exists($outputPath) | Should -BeFalse
        }
    }



}

Describe 'Post-cutover repository inventory' -Tag 'FoundationCutover' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../tools/RepositoryCatalog.psm1" -Force
        $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $scriptRoot = Join-Path $repositoryRoot 'scripts'
        $pathMap = Import-PowerShellDataFile "$repositoryRoot/evidence/foundation/PathMap.psd1"
    }

    It 'contains exactly 271 standard ps1 deployment scripts' {
        $scripts = @(Get-DeploymentScript -Root $scriptRoot)
        $scripts.Count | Should -Be 271
        $invalid = $scripts | Where-Object {
            $_.Name -notmatch '^(Detect|Remediate)-[A-Z][A-Za-z0-9]*(?:-[A-Z0-9][A-Za-z0-9]*)*\.ps1$'
        }
        $invalid | Should -BeNullOrEmpty
    }

    It 'contains no extensionless PowerShell candidates' {
        @(Get-ExtensionlessPowerShellCandidate -Root $scriptRoot) |
            Should -BeNullOrEmpty
    }

    It 'contains no lowercase legacy role prefixes' {
        $legacy = Get-ChildItem -LiteralPath $repositoryRoot -Recurse -File |
            Where-Object Name -Match '^(detection_|remediation_)'
        $legacy | Should -BeNullOrEmpty
    }

    It 'contains no legacy script path from the path map' {
        $remaining = $pathMap.Paths.BasePath | Where-Object {
            Test-Path -LiteralPath (Join-Path $repositoryRoot $_)
        }
        $remaining | Should -BeNullOrEmpty
    }

    It 'contains all 271 unique destinations from the path map' {
        @($pathMap.Paths.NewPath).Count | Should -Be 271
        @($pathMap.Paths.NewPath | Sort-Object -Unique).Count | Should -Be 271
        $missing = $pathMap.Paths.NewPath | Where-Object {
            -not (Test-Path -LiteralPath (Join-Path $scriptRoot $_) -PathType Leaf)
        }
        $missing | Should -BeNullOrEmpty
    }

    It 'uses exact mapped destination casing' {
        $actualPaths = Get-DeploymentScript -Root $scriptRoot |
            ForEach-Object {
                $_.FullName.Substring($scriptRoot.Length).
                TrimStart('\', '/').
                Replace('\', '/')
            }
        @(Compare-Object -ReferenceObject $pathMap.Paths.NewPath `
                -DifferenceObject $actualPaths -CaseSensitive) |
            Should -BeNullOrEmpty
    }

    It 'removes mapped source directories only after they become empty' {
        $emptySourceDirectories = $pathMap.Paths.BasePath |
            ForEach-Object { Split-Path -Parent $_ } |
            Sort-Object -Unique |
            Where-Object {
                $directory = Join-Path $repositoryRoot $_
                (Test-Path -LiteralPath $directory -PathType Container) -and
                @(Get-ChildItem -LiteralPath $directory -Force).Count -eq 0
            }
        $emptySourceDirectories | Should -BeNullOrEmpty
    }
}

Describe 'Foundation static style' -Tag 'FoundationStyle' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../tools/RepositoryCatalog.psm1" -Force
        $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $scriptRoot = Join-Path $repositoryRoot 'scripts'
        $packageData = Import-PowerShellDataFile "$repositoryRoot/standards/FoundationPackages.psd1"
        $styleExclusions = Get-Content `
            -LiteralPath "$repositoryRoot/evidence/foundation/StaticAnalysisExclusions.json" `
            -Raw |
            ConvertFrom-Json
        $approvedLongLineDigest = 'd43eae67fa2231aeebc5895e9e1418ca025361dca6c4643ca8c50e990c282abe'
        $scriptFiles = @(Get-DeploymentScript -Root $scriptRoot)
        $trackedPowerShellPaths = @(
            Get-FoundationTrackedPowerShellPath -RepositoryRoot $repositoryRoot |
                Where-Object { $_ -notlike 'evidence/rewrites/*' }
        )
        $trackedPowerShellFiles = @(
            foreach ($relativePath in $trackedPowerShellPaths) {
                $fullPath = Join-Path $repositoryRoot $relativePath
                if (-not [System.IO.File]::Exists($fullPath)) {
                    throw "Tracked PowerShell file '$relativePath' does not exist."
                }
                $stylePath = if ($relativePath.StartsWith('scripts/', [System.StringComparison]::OrdinalIgnoreCase)) {
                    $relativePath.Substring('scripts/'.Length)
                }
                else {
                    $relativePath
                }
                [pscustomobject]@{
                    File = Get-Item -LiteralPath $fullPath
                    Path = $stylePath
                }
            }
        )
        $parsedScripts = @{}
        $approvedVerbs = [System.Collections.Generic.HashSet[string]]::new(
            [System.StringComparer]::OrdinalIgnoreCase
        )
        foreach ($verb in Get-Verb) {
            $null = $approvedVerbs.Add([string] $verb.Verb)
        }

        foreach ($scriptFile in $scriptFiles) {
            $relativePath = $scriptFile.FullName.Substring($scriptRoot.Length).
            TrimStart('\', '/').
            Replace('\', '/')
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile(
                $scriptFile.FullName,
                [ref] $tokens,
                [ref] $parseErrors
            )
            $parsedScripts[$relativePath] = [pscustomobject]@{
                Ast = $ast
                Errors = @($parseErrors)
                File = $scriptFile
                Path = $relativePath
                Tokens = @($tokens)
            }
        }

        function Get-FoundationStyleBytes {
            param([Parameter(Mandatory)] [System.IO.FileInfo] $File)

            return [System.IO.File]::ReadAllBytes($File.FullName)
        }

        function ConvertFrom-FoundationStyleBytes {
            param([Parameter(Mandatory)] [byte[]] $Bytes)

            $offset = if (
                $Bytes.Length -ge 3 -and
                $Bytes[0] -eq 0xEF -and
                $Bytes[1] -eq 0xBB -and
                $Bytes[2] -eq 0xBF
            ) {
                3
            }
            else {
                0
            }
            $encoding = New-Object System.Text.UTF8Encoding($false, $true)
            return $encoding.GetString($Bytes, $offset, $Bytes.Length - $offset)
        }

        function Get-FoundationStyleLineHash {
            param([Parameter(Mandatory)] [string] $Text)

            $encoding = New-Object System.Text.UTF8Encoding($false)
            $hasher = [System.Security.Cryptography.SHA256]::Create()
            try {
                return ([BitConverter]::ToString(
                        $hasher.ComputeHash($encoding.GetBytes($Text))
                    )).Replace('-', '').ToLowerInvariant()
            }
            finally {
                $hasher.Dispose()
            }
        }

        function Get-FoundationStyleLineKey {
            param(
                [Parameter(Mandatory)] [string] $Path,
                [Parameter(Mandatory)] [int] $Line,
                [Parameter(Mandatory)] [string] $LineSha256
            )

            return '{0}|{1}|{2}' -f $Path, $Line, $LineSha256
        }

        function Join-FoundationStyleKeys {
            param([Parameter(Mandatory)] [object[]] $Keys)

            [string[]] $sorted = @($Keys)
            [System.Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            return ($sorted -join "`n")
        }

        function Get-FoundationStyleKeyDigest {
            param([Parameter(Mandatory)] [object[]] $Keys)

            [string[]] $sorted = @($Keys | ForEach-Object { [string] $_ })
            [System.Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            $encoding = New-Object System.Text.UTF8Encoding($false)
            $hasher = [System.Security.Cryptography.SHA256]::Create()
            try {
                return ([BitConverter]::ToString(
                        $hasher.ComputeHash($encoding.GetBytes(($sorted -join "`n")))
                    )).Replace('-', '').ToLowerInvariant()
            }
            finally {
                $hasher.Dispose()
            }
        }

        function Assert-FoundationApprovedLongLineCatalog {
            param(
                [Parameter(Mandatory)] [object[]] $Keys,
                [Parameter(Mandatory)] [string] $ExpectedDigest
            )

            $actualDigest = Get-FoundationStyleKeyDigest -Keys $Keys
            if ($actualDigest -cne $ExpectedDigest) {
                throw (
                    "The approved long-line exception digest changed. " +
                    "Expected '$ExpectedDigest'; actual '$actualDigest'."
                )
            }
        }
    }

    It 'parses all 271 deployment scripts without errors' {
        $failures = @(
            foreach ($parsed in $parsedScripts.Values) {
                foreach ($parseError in $parsed.Errors) {
                    '{0}:{1}: {2}' -f `
                        $parsed.Path,
                    $parseError.Extent.StartLineNumber,
                    $parseError.Message
                }
            }
        )

        @($parsedScripts.Values).Count | Should -Be 271
        @($failures).Count | Should -Be 0 -Because (
            "parser errors must be zero; found {0}: {1}" -f
            @($failures).Count,
            ($failures -join '; ')
        )
    }

    It 'uses no cmdlet aliases' {
        $knownAliases = [System.Collections.Generic.HashSet[string]]::new(
            [System.StringComparer]::OrdinalIgnoreCase
        )
        foreach ($aliasName in $packageData.CanonicalAliases.Keys) {
            $null = $knownAliases.Add([string] $aliasName)
        }
        $failures = @(
            foreach ($parsed in $parsedScripts.Values) {
                foreach ($command in $parsed.Ast.FindAll({
                            param($node)
                            $node -is [System.Management.Automation.Language.CommandAst]
                        }, $true)) {
                    $commandName = $command.GetCommandName()
                    if (
                        -not [string]::IsNullOrEmpty($commandName) -and
                        $knownAliases.Contains($commandName)
                    ) {
                        '{0}:{1}: {2}' -f `
                            $parsed.Path,
                        $command.Extent.StartLineNumber,
                        $commandName
                    }
                }
            }
        )

        @($failures).Count | Should -Be 0 -Because (
            "aliases must be zero; found {0}: {1}" -f
            @($failures).Count,
            ($failures -join '; ')
        )
    }

    It 'uses approved verbs for every local function' {
        $failures = @(
            foreach ($parsed in $parsedScripts.Values) {
                foreach ($function in $parsed.Ast.FindAll({
                            param($node)
                            $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
                        }, $true)) {
                    $separator = $function.Name.IndexOf('-')
                    $verb = if ($separator -gt 0) {
                        $function.Name.Substring(0, $separator)
                    }
                    else {
                        $function.Name
                    }
                    if ($separator -lt 1 -or -not $approvedVerbs.Contains($verb)) {
                        '{0}:{1}: {2}' -f `
                            $parsed.Path,
                        $function.Extent.StartLineNumber,
                        $function.Name
                    }
                }
            }
        )

        @($failures).Count | Should -Be 0 -Because (
            "unapproved local function verbs must be zero; found {0}: {1}" -f
            @($failures).Count,
            ($failures -join '; ')
        )
    }

    It 'uses canonical casing for every reviewed cmdlet' {
        $canonicalCmdlets = [System.Collections.Generic.Dictionary[string, string]]::new(
            [System.StringComparer]::OrdinalIgnoreCase
        )
        foreach ($canonicalName in $packageData.CanonicalCmdlets) {
            $canonicalCmdlets.Add([string] $canonicalName, [string] $canonicalName)
        }
        $failures = @(
            foreach ($parsed in $parsedScripts.Values) {
                foreach ($command in $parsed.Ast.FindAll({
                            param($node)
                            $node -is [System.Management.Automation.Language.CommandAst]
                        }, $true)) {
                    $commandName = $command.GetCommandName()
                    if (
                        -not [string]::IsNullOrEmpty($commandName) -and
                        $canonicalCmdlets.ContainsKey($commandName) -and
                        $commandName -cne $canonicalCmdlets[$commandName]
                    ) {
                        '{0}:{1}: {2} -> {3}' -f `
                            $parsed.Path,
                        $command.Extent.StartLineNumber,
                        $commandName,
                        $canonicalCmdlets[$commandName]
                    }
                }
            }
        )

        @($failures).Count | Should -Be 0 -Because (
            "cmdlet casing differences must be zero; found {0}: {1}" -f
            @($failures).Count,
            ($failures -join '; ')
        )
    }

    It 'uses UTF-8 with BOM for every deployment script' {
        $failures = @(
            foreach ($parsed in $parsedScripts.Values) {
                $bytes = Get-FoundationStyleBytes -File $parsed.File
                if (
                    $bytes.Length -lt 3 -or
                    $bytes[0] -ne 0xEF -or
                    $bytes[1] -ne 0xBB -or
                    $bytes[2] -ne 0xBF
                ) {
                    $parsed.Path
                    continue
                }
                try {
                    $null = ConvertFrom-FoundationStyleBytes -Bytes $bytes
                }
                catch {
                    '{0}: {1}' -f $parsed.Path, $_.Exception.Message
                }
            }
        )

        @($failures).Count | Should -Be 0 -Because (
            "non-BOM or invalid UTF-8 scripts must be zero; found {0}: {1}" -f
            @($failures).Count,
            ($failures -join '; ')
        )
    }

    It 'uses LF line endings' {
        $failures = @(
            foreach ($parsed in $parsedScripts.Values) {
                $bytes = Get-FoundationStyleBytes -File $parsed.File
                if ($bytes -contains 0x0D) {
                    $parsed.Path
                }
            }
        )

        @($failures).Count | Should -Be 0 -Because (
            "scripts containing non-LF line endings must be zero; found {0}: {1}" -f
            @($failures).Count,
            ($failures -join '; ')
        )
    }

    It 'matches the exact preserved tab exceptions in two comment-help blocks' {
        $actual = @(
            foreach ($parsed in $parsedScripts.Values) {
                $text = ConvertFrom-FoundationStyleBytes -Bytes (
                    Get-FoundationStyleBytes -File $parsed.File
                )
                $lineNumber = 0
                foreach ($line in $text.Split("`n")) {
                    $lineNumber++
                    if ($line.Contains("`t")) {
                        Get-FoundationStyleLineKey `
                            -Path $parsed.Path `
                            -Line $lineNumber `
                            -LineSha256 (Get-FoundationStyleLineHash -Text $line)
                    }
                }
            }
        )
        $expected = @($styleExclusions.SensitiveWhitespace |
                Where-Object Rule -CEQ 'Tab' |
                ForEach-Object {
                    Get-FoundationStyleLineKey `
                        -Path $_.Path `
                        -Line $_.Line `
                        -LineSha256 $_.LineSha256
                })

        $expected.Count | Should -Be 6
        Join-FoundationStyleKeys -Keys $actual |
            Should -BeExactly (Join-FoundationStyleKeys -Keys $expected)
    }

    It 'matches the exact preserved trailing whitespace in help and here-string content' {
        $actual = @(
            foreach ($parsed in $parsedScripts.Values) {
                $text = ConvertFrom-FoundationStyleBytes -Bytes (
                    Get-FoundationStyleBytes -File $parsed.File
                )
                $lineNumber = 0
                foreach ($line in $text.Split("`n")) {
                    $lineNumber++
                    if ($line -match '[ \t]+$') {
                        Get-FoundationStyleLineKey `
                            -Path $parsed.Path `
                            -Line $lineNumber `
                            -LineSha256 (Get-FoundationStyleLineHash -Text $line)
                    }
                }
            }
        )
        $expected = @($styleExclusions.SensitiveWhitespace |
                Where-Object Rule -CEQ 'TrailingWhitespace' |
                ForEach-Object {
                    Get-FoundationStyleLineKey `
                        -Path $_.Path `
                        -Line $_.Line `
                        -LineSha256 $_.LineSha256
                })

        $expected.Count | Should -Be 4
        Join-FoundationStyleKeys -Keys $actual |
            Should -BeExactly (Join-FoundationStyleKeys -Keys $expected)
    }

    It 'ends every deployment script with an LF newline' {
        $failures = @(
            foreach ($parsed in $parsedScripts.Values) {
                $bytes = Get-FoundationStyleBytes -File $parsed.File
                if (
                    $bytes.Length -eq 0 -or
                    $bytes[$bytes.Length - 1] -ne 0x0A
                ) {
                    $parsed.Path
                }
            }
        )

        @($failures).Count | Should -Be 0 -Because (
            "scripts without a final LF newline must be zero; found {0}: {1}" -f
            @($failures).Count,
            ($failures -join '; ')
        )
    }

    It 'enforces 120 columns across every tracked PowerShell file with exact catalog exceptions' {
        $actual = @(
            foreach ($trackedFile in $trackedPowerShellFiles) {
                $lines = [System.IO.File]::ReadAllLines($trackedFile.File.FullName)
                for ($index = 0; $index -lt $lines.Count; $index++) {
                    $line = [string] $lines[$index]
                    if (
                        $line.Length -gt 120 -and
                        $line -notmatch 'https?://' -and
                        $line -notmatch '(?i)\b[0-9a-f]{64,}\b'
                    ) {
                        Get-FoundationStyleLineKey `
                            -Path $trackedFile.Path `
                            -Line ($index + 1) `
                            -LineSha256 (Get-FoundationStyleLineHash -Text $line)
                    }
                }
            }
        )
        $expected = @($styleExclusions.LongLines | ForEach-Object {
                Get-FoundationStyleLineKey `
                    -Path $_.Path `
                    -Line $_.Line `
                    -LineSha256 $_.LineSha256
            })

        $trackedPowerShellFiles.Count | Should -Be $trackedPowerShellPaths.Count
        $trackedPowerShellFiles.Count | Should -Be 577
        $expected.Count | Should -Be 93
        Assert-FoundationApprovedLongLineCatalog `
            -Keys $expected `
            -ExpectedDigest $approvedLongLineDigest
        Join-FoundationStyleKeys -Keys $actual |
            Should -BeExactly (Join-FoundationStyleKeys -Keys $expected)
    }

    It 'rejects a substituted long-line exception even when the row count remains 93' {
        [string[]] $expected = @($styleExclusions.LongLines | ForEach-Object {
                Get-FoundationStyleLineKey `
                    -Path $_.Path `
                    -Line $_.Line `
                    -LineSha256 $_.LineSha256
            })
        [string[]] $mutated = @($expected)
        $mutated[0] = 'Substituted/Detect-Substituted.ps1|1|{0}' -f ('0' * 64)

        $mutated.Count | Should -Be 93
        {
            Assert-FoundationApprovedLongLineCatalog `
                -Keys $mutated `
                -ExpectedDigest $approvedLongLineDigest
        } | Should -Throw '*approved long-line exception digest*'
    }

    It 'delegates the configured long-line rule only to the tracked-file repository test' {
        $settingsPath = Join-Path $repositoryRoot 'PSScriptAnalyzerSettings.psd1'
        $settings = Import-PowerShellDataFile $settingsPath
        $expectedRules = @(
            'PSAvoidUsingCmdletAliases'
            'PSUseApprovedVerbs'
            'PSAvoidUsingInvokeExpression'
            'PSUseConsistentIndentation'
            'PSUseConsistentWhitespace'
            'PSPlaceOpenBrace'
            'PSPlaceCloseBrace'
            'PSAvoidLongLines'
        )

        @($settings.IncludeRules) | Should -BeExactly $expectedRules
        @($settings.ExcludeRules) | Should -BeExactly @('PSAvoidLongLines')
        $settings.Rules.PSAvoidLongLines.Enable | Should -BeTrue
        $settings.Rules.PSAvoidLongLines.MaximumLineLength | Should -Be 120
    }

    It 'returns zero recursive analyzer findings for the other seven configured rules' {
        Import-Module PSScriptAnalyzer -RequiredVersion 1.25.0 -Force
        $settingsPath = Join-Path $repositoryRoot 'PSScriptAnalyzerSettings.psd1'
        $findings = @(
            Invoke-ScriptAnalyzer `
                -Path $repositoryRoot `
                -Recurse `
                -Settings $settingsPath
        )

        $findings | Should -BeNullOrEmpty
    }
}

Describe 'Foundation mover dirty-tree preconditions' -Tag 'FoundationCutover' {
    BeforeAll {
        $foundationMover = [System.IO.Path]::GetFullPath(
            (Join-Path $PSScriptRoot '../tools/Invoke-FoundationMove.ps1')
        )

        function Invoke-FixtureGit {
            param(
                [Parameter(Mandatory)]
                [string] $Root,

                [Parameter(Mandatory)]
                [string[]] $Arguments
            )

            $originalGitDirectory = $env:GIT_DIR
            $originalGitWorkTree = $env:GIT_WORK_TREE
            try {
                $env:GIT_DIR = $null
                $env:GIT_WORK_TREE = $null
                $output = @(& git -C $Root @Arguments 2>&1)
                $exitCode = $LASTEXITCODE
            }
            finally {
                $env:GIT_DIR = $originalGitDirectory
                $env:GIT_WORK_TREE = $originalGitWorkTree
            }
            if ($exitCode -ne 0) {
                throw "git $($Arguments -join ' ') failed: $($output -join [Environment]::NewLine)"
            }

            return $output
        }

        function New-FoundationMoveFixture {
            param(
                [Parameter(Mandatory)]
                [string] $Root,

                [int] $UntrackedIndex = -1,

                [byte[]] $UntrackedBytes = @()
            )

            $legacyDirectory = Join-Path $Root 'Legacy'
            $mapDirectory = Join-Path $Root 'evidence/foundation'
            [void] [System.IO.Directory]::CreateDirectory($legacyDirectory)
            [void] [System.IO.Directory]::CreateDirectory($mapDirectory)

            $mapLines = @(
                '@{'
                '    Paths = @('
                for ($index = 0; $index -lt 271; $index++) {
                    $fileName = 'Detect-Fixture-{0:D3}.ps1' -f $index
                    $sourceRelativePath = "Legacy/$fileName"
                    $destinationRelativePath = "Standard/$fileName"
                    "        @{ BasePath = '$sourceRelativePath'; NewPath = '$destinationRelativePath' }"

                    if ($index -ne $UntrackedIndex) {
                        $sourcePath = Join-Path $Root $sourceRelativePath
                        $sourceBytes = [System.Text.Encoding]::UTF8.GetBytes(
                            "Write-Output '$index'`n"
                        )
                        [System.IO.File]::WriteAllBytes($sourcePath, $sourceBytes)
                    }
                }
                '    )'
                '}'
            )

            $mapPath = Join-Path $mapDirectory 'PathMap.psd1'
            [System.IO.File]::WriteAllLines(
                $mapPath,
                $mapLines,
                [System.Text.UTF8Encoding]::new($false)
            )

            [void] (Invoke-FixtureGit -Root $Root -Arguments @('init', '--quiet'))
            [void] (Invoke-FixtureGit -Root $Root -Arguments @(
                    'config', 'user.email', 'foundation-mover@example.invalid'
                ))
            [void] (Invoke-FixtureGit -Root $Root -Arguments @(
                    'config', 'user.name', 'Foundation Mover Tests'
                ))
            [void] (Invoke-FixtureGit -Root $Root -Arguments @(
                    'add', '--', 'evidence/foundation/PathMap.psd1', 'Legacy'
                ))
            [void] (Invoke-FixtureGit -Root $Root -Arguments @(
                    'commit', '--quiet', '-m', 'fixture'
                ))

            $selectedIndex = if ($UntrackedIndex -ge 0) {
                $UntrackedIndex
            }
            else {
                0
            }
            $selectedFileName = 'Detect-Fixture-{0:D3}.ps1' -f $selectedIndex
            $selectedSourceRelativePath = "Legacy/$selectedFileName"
            $selectedDestinationRelativePath = "Standard/$selectedFileName"
            $selectedSourcePath = Join-Path $Root $selectedSourceRelativePath
            if ($UntrackedIndex -ge 0) {
                [System.IO.File]::WriteAllBytes($selectedSourcePath, $UntrackedBytes)
            }

            return [pscustomobject]@{
                Root = $Root
                SourceRelativePath = $selectedSourceRelativePath
                DestinationRelativePath = $selectedDestinationRelativePath
                SourcePath = $selectedSourcePath
                DestinationPath = Join-Path $Root $selectedDestinationRelativePath
            }
        }

        function Invoke-FoundationMoveFixture {
            param(
                [Parameter(Mandatory)]
                [string] $Root
            )

            Push-Location $Root
            try {
                & $foundationMover -PathMap './evidence/foundation/PathMap.psd1'
            }
            finally {
                Pop-Location
            }
        }
    }

    It 'moves an approved untracked mapped source ordinarily and byte-identically' {
        $expectedBytes = [byte[]] @(0, 10, 13, 65, 128, 254, 255)
        $fixture = New-FoundationMoveFixture `
            -Root (Join-Path $TestDrive 'approved-untracked') `
            -UntrackedIndex 270 `
            -UntrackedBytes $expectedBytes

        $output = @(Invoke-FoundationMoveFixture -Root $fixture.Root)

        $output | Should -BeExactly 'Moved 271 foundation scripts with byte-identical content.'
        Test-Path -LiteralPath $fixture.SourcePath | Should -BeFalse
        Test-Path -LiteralPath $fixture.DestinationPath -PathType Leaf | Should -BeTrue
        [Convert]::ToBase64String(
            [System.IO.File]::ReadAllBytes($fixture.DestinationPath)
        ) | Should -BeExactly 'AAoNQYD+/w=='
        @(Invoke-FixtureGit -Root $fixture.Root -Arguments @(
                'ls-files', '--', $fixture.DestinationRelativePath
            )) | Should -BeNullOrEmpty
        @(Invoke-FixtureGit -Root $fixture.Root -Arguments @(
                'status', '--short', '--untracked-files=all'
            )) | Should -Contain "?? $($fixture.DestinationRelativePath)"
    }

    It 'rejects an unrelated untracked path' {
        $fixture = New-FoundationMoveFixture `
            -Root (Join-Path $TestDrive 'unrelated-untracked')
        [System.IO.File]::WriteAllBytes(
            (Join-Path $fixture.Root 'unrelated.bin'),
            [byte[]] @(1, 2, 3)
        )

        {
            Invoke-FoundationMoveFixture -Root $fixture.Root
        } | Should -Throw '*unrelated.bin*'
        Test-Path -LiteralPath $fixture.SourcePath -PathType Leaf | Should -BeTrue
        Test-Path -LiteralPath $fixture.DestinationPath | Should -BeFalse
    }

    It 'rejects a modified mapped runtime source' {
        $fixture = New-FoundationMoveFixture `
            -Root (Join-Path $TestDrive 'modified-runtime')
        [System.IO.File]::WriteAllBytes($fixture.SourcePath, [byte[]] @(4, 5, 6))

        {
            Invoke-FoundationMoveFixture -Root $fixture.Root
        } | Should -Throw "*$($fixture.SourceRelativePath)*"
        Test-Path -LiteralPath $fixture.SourcePath -PathType Leaf | Should -BeTrue
        Test-Path -LiteralPath $fixture.DestinationPath | Should -BeFalse
    }

    It 'rejects a staged mapped runtime source' {
        $fixture = New-FoundationMoveFixture `
            -Root (Join-Path $TestDrive 'staged-runtime')
        [System.IO.File]::WriteAllBytes($fixture.SourcePath, [byte[]] @(7, 8, 9))
        [void] (Invoke-FixtureGit -Root $fixture.Root -Arguments @(
                'add', '--', $fixture.SourceRelativePath
            ))

        {
            Invoke-FoundationMoveFixture -Root $fixture.Root
        } | Should -Throw "*$($fixture.SourceRelativePath)*"
        Test-Path -LiteralPath $fixture.SourcePath -PathType Leaf | Should -BeTrue
        Test-Path -LiteralPath $fixture.DestinationPath | Should -BeFalse
    }
}

Describe 'Foundation repository Git discovery' -Tag 'FoundationGitDiscovery' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../tools/RepositoryCatalog.psm1" -Force
        function Invoke-FoundationGitFixtureCommand {
            param(
                [Parameter(Mandatory)] [string] $Root,
                [Parameter(Mandatory)] [string[]] $Arguments
            )

            $originalGitDirectory = $env:GIT_DIR
            $originalGitWorkTree = $env:GIT_WORK_TREE
            try {
                $env:GIT_DIR = $null
                $env:GIT_WORK_TREE = $null
                $output = @(& git -C $Root @Arguments 2>&1)
                $exitCode = $LASTEXITCODE
            }
            finally {
                $env:GIT_DIR = $originalGitDirectory
                $env:GIT_WORK_TREE = $originalGitWorkTree
            }
            if ($exitCode -ne 0) {
                throw "git $($Arguments -join ' ') failed: $($output -join [Environment]::NewLine)"
            }
            return $output
        }

        function New-FoundationExternalWorktreeFixture {
            param(
                [Parameter(Mandatory)] [string] $Root,
                [Parameter(Mandatory)] [string] $Name,
                [string] $TrackedFile = 'fixture.ps1'
            )

            $mainRoot = Join-Path $Root 'main'
            $worktreeRoot = Join-Path $Root 'external-review'
            [void] [System.IO.Directory]::CreateDirectory($mainRoot)
            [void] (Invoke-FoundationGitFixtureCommand -Root $mainRoot -Arguments @(
                    'init', '--quiet'
                ))
            [void] (Invoke-FoundationGitFixtureCommand -Root $mainRoot -Arguments @(
                    'config', 'user.email', 'foundation-style@example.invalid'
                ))
            [void] (Invoke-FoundationGitFixtureCommand -Root $mainRoot -Arguments @(
                    'config', 'user.name', 'Foundation Style Tests'
                ))
            [System.IO.File]::WriteAllText(
                (Join-Path $mainRoot $TrackedFile),
                "Write-Output 'fixture'`n",
                [System.Text.UTF8Encoding]::new($false)
            )
            [void] (Invoke-FoundationGitFixtureCommand -Root $mainRoot -Arguments @(
                    'add', '--', $TrackedFile
                ))
            [void] (Invoke-FoundationGitFixtureCommand -Root $mainRoot -Arguments @(
                    'commit', '--quiet', '-m', 'fixture'
                ))
            [void] (Invoke-FoundationGitFixtureCommand -Root $mainRoot -Arguments @(
                    'worktree', 'add', '--quiet', '-b', "review-$Name", $worktreeRoot
                ))

            $pointerPath = Join-Path $worktreeRoot '.git'
            $pointer = [System.IO.File]::ReadAllText($pointerPath).Trim()
            if ($pointer -notmatch '^gitdir:\s+(.+)$') {
                throw "Invalid fixture Git pointer '$pointerPath'."
            }
            $gitDirectory = $Matches[1]
            if (-not [System.IO.Path]::IsPathRooted($gitDirectory)) {
                $gitDirectory = Join-Path (Split-Path $pointerPath -Parent) $gitDirectory
            }

            return [pscustomobject]@{
                GitDirectory = [System.IO.Path]::GetFullPath($gitDirectory)
                PointerPath = $pointerPath
                WorktreeRoot = $worktreeRoot
            }
        }

        function Set-FoundationInvalidGitPointer {
            param([Parameter(Mandatory)] [string] $Path)

            [System.IO.File]::SetAttributes($Path, [System.IO.FileAttributes]::Normal)
            [System.IO.File]::WriteAllText(
                $Path,
                'gitdir: Z:\unusable\external-review',
                [System.Text.UTF8Encoding]::new($false)
            )
        }
    }

    It 'uses the literal pointer for an externally located linked worktree' {
        $originalGitDirectory = $env:GIT_DIR
        $originalGitWorkTree = $env:GIT_WORK_TREE
        try {
            $env:GIT_DIR = $null
            $env:GIT_WORK_TREE = $null
            $fixture = New-FoundationExternalWorktreeFixture `
                -Root (Join-Path $TestDrive 'literal-pointer') `
                -Name 'literal'

            $context = Resolve-FoundationRepositoryGitContext `
                -RepositoryRoot $fixture.WorktreeRoot
            $tracked = @(Get-FoundationTrackedPowerShellPath `
                    -RepositoryRoot $fixture.WorktreeRoot)

            $context.GitDirectory | Should -BeExactly $fixture.GitDirectory
            $context.WorkTree | Should -Be $fixture.WorktreeRoot
            $tracked | Should -Contain 'fixture.ps1'
        }
        finally {
            $env:GIT_DIR = $originalGitDirectory
            $env:GIT_WORK_TREE = $originalGitWorkTree
        }
    }

    It 'prefers valid explicit Git environment paths over an unusable pointer' {
        $fixture = New-FoundationExternalWorktreeFixture `
            -Root (Join-Path $TestDrive 'explicit-environment') `
            -Name 'environment'
        Set-FoundationInvalidGitPointer -Path $fixture.PointerPath
        $originalGitDirectory = $env:GIT_DIR
        $originalGitWorkTree = $env:GIT_WORK_TREE
        try {
            $env:GIT_DIR = $fixture.GitDirectory
            $env:GIT_WORK_TREE = $fixture.WorktreeRoot

            $tracked = @(Get-FoundationTrackedPowerShellPath `
                    -RepositoryRoot $fixture.WorktreeRoot)

            $tracked | Should -Contain 'fixture.ps1'
        }
        finally {
            $env:GIT_DIR = $originalGitDirectory
            $env:GIT_WORK_TREE = $originalGitWorkTree
        }
    }

    It 'ignores a valid explicit Git context for another repository root' {
        $repositoryA = New-FoundationExternalWorktreeFixture `
            -Root (Join-Path $TestDrive 'mismatched-environment-a') `
            -Name 'mismatched-a' `
            -TrackedFile 'repo-a.ps1'
        $repositoryB = New-FoundationExternalWorktreeFixture `
            -Root (Join-Path $TestDrive 'mismatched-environment-b') `
            -Name 'mismatched-b' `
            -TrackedFile 'repo-b.ps1'
        $originalGitDirectory = $env:GIT_DIR
        $originalGitWorkTree = $env:GIT_WORK_TREE
        try {
            $env:GIT_DIR = $repositoryA.GitDirectory
            $env:GIT_WORK_TREE = $repositoryA.WorktreeRoot

            $context = Resolve-FoundationRepositoryGitContext `
                -RepositoryRoot $repositoryB.WorktreeRoot
            $tracked = @(Get-FoundationTrackedPowerShellPath `
                    -RepositoryRoot $repositoryB.WorktreeRoot)

            ($tracked -join ',') | Should -BeExactly 'repo-b.ps1'
            $comparison = if (
                [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
            ) {
                [System.StringComparison]::OrdinalIgnoreCase
            }
            else {
                [System.StringComparison]::Ordinal
            }
            [string]::Equals(
                [System.IO.Path]::GetFullPath($context.WorkTree).TrimEnd('\', '/'),
                [System.IO.Path]::GetFullPath($repositoryB.WorktreeRoot).TrimEnd('\', '/'),
                $comparison
            ) | Should -BeTrue
        }
        finally {
            $env:GIT_DIR = $originalGitDirectory
            $env:GIT_WORK_TREE = $originalGitWorkTree
        }
    }

    It 'throws for an unusable cross-OS pointer before returning an empty scan' {
        $fixture = New-FoundationExternalWorktreeFixture `
            -Root (Join-Path $TestDrive 'invalid-pointer') `
            -Name 'invalid'
        Set-FoundationInvalidGitPointer -Path $fixture.PointerPath
        $originalGitDirectory = $env:GIT_DIR
        $originalGitWorkTree = $env:GIT_WORK_TREE
        try {
            $env:GIT_DIR = $null
            $env:GIT_WORK_TREE = $null

            {
                @(Get-FoundationTrackedPowerShellPath `
                        -RepositoryRoot $fixture.WorktreeRoot)
            } | Should -Throw '*Unable to resolve repository Git context*'
        }
        finally {
            $env:GIT_DIR = $originalGitDirectory
            $env:GIT_WORK_TREE = $originalGitWorkTree
        }
    }
}
Describe 'Build quality interface' -Tag 'BuildInterface' {
    $windowsPowerShellPath = if (-not [string]::IsNullOrEmpty($env:SystemRoot)) {
        Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'
    }
    else {
        ''
    }

    BeforeAll {
        $windowsPowerShellPath = if (-not [string]::IsNullOrEmpty($env:SystemRoot)) {
            Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'
        }
        else {
            ''
        }
        $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $buildPath = Join-Path $repositoryRoot 'build.ps1'
        $powerShellPath = if (
            [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
            [System.IO.File]::Exists($windowsPowerShellPath)
        ) {
            $windowsPowerShellPath
        }
        else {
            (Get-Command pwsh -ErrorAction SilentlyContinue).Path
        }
        $canInvokeBuild = -not [string]::IsNullOrWhiteSpace($powerShellPath)

        function New-BuildContractFixture {
            param(
                [Parameter(Mandatory)]
                [ValidateSet('Validate', 'Analyze', 'Test', 'CheckFormat', 'ValidateRewrite')]
                [string] $Route
            )

            $root = Join-Path $TestDrive ('BuildInterface-' + [guid]::NewGuid().ToString('N'))
            $moduleRoot = Join-Path $root 'modules'
            foreach ($directory in @(
                    $root,
                    (Join-Path $root 'tools'),
                    (Join-Path $root 'standards'),
                    (Join-Path $root 'evidence'),
                    (Join-Path $root 'evidence/foundation'),
                    (Join-Path $root 'tests'),
                    (Join-Path $root 'scripts/runtime'),
                    (Join-Path $moduleRoot 'Pester'),
                    (Join-Path $moduleRoot 'PSScriptAnalyzer')
                )) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
            }
            Copy-Item -LiteralPath $buildPath -Destination (Join-Path $root 'build.ps1')
            Set-Content -LiteralPath (Join-Path $root 'PSScriptAnalyzerSettings.psd1') `
                -Value '@{}' -Encoding utf8
            Set-Content -LiteralPath (Join-Path $root 'tests/Repository.Tests.ps1') `
                -Value 'param([string[]] $Tag)' -Encoding utf8
            Set-Content -LiteralPath (Join-Path $root 'standards/ManifestSchema.psd1') `
                -Value '@{}' -Encoding utf8
            if ($Route -eq 'Validate') {
                $manifestGenerator = @'
param(
    [string] $PathMap,
    [string] $Metadata,
    [string] $Schema,
    [string] $OutputRoot
)
$map = Import-PowerShellDataFile -LiteralPath $PathMap
foreach ($row in @($map.Paths)) {
    $manifestPath = Join-Path $OutputRoot ([System.IO.Path]::ChangeExtension(
            [string] $row.NewPath,
            '.psd1'
        ))
    New-Item -ItemType Directory -Path (Split-Path $manifestPath) -Force | Out-Null
    Set-Content -LiteralPath $manifestPath -Value '@{}' -Encoding utf8
}
'@
                Set-Content -LiteralPath (Join-Path $root 'tools/New-ScriptManifest.ps1') `
                    -Value $manifestGenerator -Encoding utf8
            }

            $requiredModules = if ($Route -eq 'Analyze') {
                "@{ PSScriptAnalyzer = @{ Version = '1.25.0'; Repository = 'PSGallery' } }"
            }
            elseif ($Route -in @('Validate', 'Test', 'CheckFormat')) {
                "@{ Pester = @{ Version = '5.7.1'; Repository = 'PSGallery' } }"
            }
            else {
                '@{}'
            }
            Set-Content -LiteralPath (Join-Path $root 'tools/RequiredModules.psd1') `
                -Value $requiredModules -Encoding utf8

            $pesterModule = @'
function New-PesterConfiguration {
    [pscustomobject]@{
        Run = [pscustomobject]@{
            Path = $null
            Exit = $null
            PassThru = $null
        }
        CodeCoverage = [pscustomobject]@{
            Enabled = $false
            Path = @()
        }
    }
}
function Invoke-Pester {
    param(
        [pscustomobject] $Configuration,
        [string] $Path,
        [string[]] $Tag,
        [string] $Output,
        [switch] $PassThru
    )
    $record = [ordered]@{
        Command = 'Invoke-Pester'
        Configuration = $null
    }
    if ($null -ne $Configuration) {
        $record.Configuration = [ordered]@{
            RunPath = @($Configuration.Run.Path)
            RunExit = [bool] $Configuration.Run.Exit
            RunPassThru = [bool] $Configuration.Run.PassThru
            CoverageEnabled = [bool] $Configuration.CodeCoverage.Enabled
            CoveragePath = @($Configuration.CodeCoverage.Path)
        }
    }
    else {
        $record.Path = $Path
        $record.Tag = @($Tag)
        $record.Output = $Output
        $record.PassThru = $PassThru.IsPresent
    }
    [System.IO.File]::AppendAllText(
        $env:BUILD_CONTRACT_LOG,
        (($record | ConvertTo-Json -Compress) + [Environment]::NewLine)
    )
    $failedCount = if ($env:BUILD_CONTRACT_FAILURE -eq '1') { 1 } else { 0 }
    if ($env:BUILD_CONTRACT_EXECUTE_TEST_FIXTURE -eq '1' -and
        $null -ne $Path -and
        [System.IO.File]::Exists($Path)) {
        try {
            $global:LASTEXITCODE = 0
            & $Path -Tag $Tag
            if ($LASTEXITCODE -ne 0) {
                $failedCount = 1
            }
        }
        catch {
            $failedCount = 1
        }
    }
    $resultState = if (-not [string]::IsNullOrWhiteSpace($env:BUILD_CONTRACT_RESULT)) {
        [string] $env:BUILD_CONTRACT_RESULT
    }
    elseif ($failedCount -eq 0) {
        'Passed'
    }
    else {
        'Failed'
    }
    [pscustomobject]@{
        Result = $resultState
        FailedCount = $failedCount
        PassedCount = if ($failedCount -eq 0) { 1 } else { 0 }
        SkippedCount = 0
    }
}
'@
            $pesterManifest = @"
@{
    RootModule = 'Pester.psm1'
    ModuleVersion = '5.7.1'
    GUID = '$([guid]::NewGuid())'
    FunctionsToExport = @('New-PesterConfiguration', 'Invoke-Pester')
}
"@
            Set-Content -LiteralPath (Join-Path $moduleRoot 'Pester/Pester.psm1') `
                -Value $pesterModule -Encoding utf8
            Set-Content -LiteralPath (Join-Path $moduleRoot 'Pester/Pester.psd1') `
                -Value $pesterManifest -Encoding utf8

            $analyzerModule = @'
function Invoke-ScriptAnalyzer {
    param(
        [string] $Path,
        [switch] $Recurse,
        [string] $Settings
    )
    $record = [ordered]@{
        Command = 'Invoke-ScriptAnalyzer'
        Path = $Path
        Recurse = $Recurse.IsPresent
        Settings = $Settings
    }
    [System.IO.File]::AppendAllText(
        $env:BUILD_CONTRACT_LOG,
        (($record | ConvertTo-Json -Compress) + [Environment]::NewLine)
    )
}
'@
            $analyzerManifest = @"
@{
    RootModule = 'PSScriptAnalyzer.psm1'
    ModuleVersion = '1.25.0'
    GUID = '$([guid]::NewGuid())'
    FunctionsToExport = @('Invoke-ScriptAnalyzer')
}
"@
            Set-Content -LiteralPath (Join-Path $moduleRoot 'PSScriptAnalyzer/PSScriptAnalyzer.psm1') `
                -Value $analyzerModule -Encoding utf8
            Set-Content -LiteralPath (Join-Path $moduleRoot 'PSScriptAnalyzer/PSScriptAnalyzer.psd1') `
                -Value $analyzerManifest -Encoding utf8

            if ($Route -in @('Validate', 'Test')) {
                $catalogModule = @'
function Write-CatalogContractLog {
    param([string] $Command, [hashtable] $Arguments)
    $record = [ordered]@{ Command = $Command }
    foreach ($key in $Arguments.Keys) {
        $record[$key] = $Arguments[$key]
    }
    [System.IO.File]::AppendAllText(
        $env:BUILD_CONTRACT_LOG,
        (($record | ConvertTo-Json -Compress) + [Environment]::NewLine)
    )
}
function Get-DeploymentScript {
    param([string] $Root)
    Write-CatalogContractLog 'Get-DeploymentScript' @{ Root = $Root }
    Get-ChildItem -LiteralPath (Join-Path $Root 'runtime') -Filter '*.ps1' -File
}
function Test-ScriptManifest {
    param([string] $Path, [string] $SchemaPath)
    Write-CatalogContractLog 'Test-ScriptManifest' @{
        Path = $Path
        SchemaPath = $SchemaPath
    }
    [pscustomobject]@{
        Valid = $true
        Errors = @()
        Manifest = @{ Test = @{ Status = 'Covered' } }
    }
}
function Test-ManifestStatusTransition {
    param([string] $Before, [string] $After)
    Write-CatalogContractLog 'Test-ManifestStatusTransition' @{
        Before = $Before
        After = $After
    }
    $true
}
function Get-UnresolvedRepositoryReference {
    param([string] $Root)
    Write-CatalogContractLog 'Get-UnresolvedRepositoryReference' @{ Root = $Root }
    @()
}
Export-ModuleMember -Function *
'@
                Set-Content -LiteralPath (Join-Path $root 'tools/RepositoryCatalog.psm1') `
                    -Value $catalogModule -Encoding utf8
            }

            $runtimePath = Join-Path $root 'scripts/runtime/Script001.ps1'
            $scriptContent = @'
if (-not [string]::IsNullOrEmpty($env:BUILD_CONTRACT_SENTINEL)) {
    Add-Content -LiteralPath $env:BUILD_CONTRACT_SENTINEL `
        -Value $MyInvocation.MyCommand.Path
}
'@
            Set-Content -LiteralPath $runtimePath -Value $scriptContent -Encoding utf8
            Set-Content -LiteralPath (Join-Path $root 'scripts/runtime/Script001.psd1') `
                -Value '@{}' -Encoding utf8

            if ($Route -eq 'Validate') {
                $mapEntries = @(
                    foreach ($number in 1..271) {
                        $name = 'Script{0:D3}.ps1' -f $number
                        $path = Join-Path $root "scripts/runtime/$name"
                        Set-Content -LiteralPath $path -Value $scriptContent -Encoding utf8
                        Set-Content -LiteralPath ([System.IO.Path]::ChangeExtension($path, '.psd1')) `
                            -Value '@{}' -Encoding utf8
                        "@{ NewPath = 'runtime/$name' }"
                    }
                )
                Set-Content -LiteralPath (Join-Path $root 'evidence/PathMap.psd1') -Value (
                    "@{ Paths = @(`n" +
                    (($mapEntries -join ",`n") + "`n") +
                    ') }'
                ) -Encoding utf8
                New-Item -ItemType Directory -Path (Join-Path $root 'evidence/foundation') -Force |
                    Out-Null
                Copy-Item -LiteralPath (Join-Path $root 'evidence/PathMap.psd1') `
                    -Destination (Join-Path $root 'evidence/foundation/PathMap.psd1')
            }
            else {
                Set-Content -LiteralPath (Join-Path $root 'evidence/foundation/PathMap.psd1') `
                    -Value '@{ Paths = @() }' -Encoding utf8
            }
            if ($Route -eq 'ValidateRewrite') {
                Set-Content -LiteralPath (Join-Path $root 'evidence/foundation/BaseRevision.txt') `
                    -Value ('a' * 40) -Encoding ascii
                Set-Content -LiteralPath (Join-Path $root 'evidence/foundation/SymbolRenames.psd1') `
                    -Value '@{ Commands = @(); Aliases = @() }' -Encoding utf8
                $rewriteGate = @'
param(
    [string] $BaseRevision,
    [string] $PathMap,
    [string] $SymbolMap,
    [string] $ReportPath
)
$record = [ordered]@{
    Command = 'Test-PowerShellRewrite'
    BaseRevision = $BaseRevision
    PathMap = $PathMap
    SymbolMap = $SymbolMap
    ReportPath = $ReportPath
}
[System.IO.File]::AppendAllText(
    $env:BUILD_CONTRACT_LOG,
    (($record | ConvertTo-Json -Compress) + [Environment]::NewLine)
)
exit 0
'@
                Set-Content -LiteralPath (Join-Path $root 'tools/Test-PowerShellRewrite.ps1') `
                    -Value $rewriteGate -Encoding utf8
            }
            $root
        }
        function Invoke-BuildContractFixture {
            param(
                [Parameter(Mandatory)] [string] $FixtureRoot,
                [string[]] $Arguments = @(),
                [string] $PesterResult
            )

            $logPath = Join-Path $TestDrive ('BuildInterface-' + [guid]::NewGuid().ToString('N') + '.jsonl')
            $sentinelPath = Join-Path $TestDrive ('BuildInterface-' + [guid]::NewGuid().ToString('N') + '.sentinel')
            $originalModulePath = $env:PSModulePath
            $originalLogPath = $env:BUILD_CONTRACT_LOG
            $originalSentinelPath = $env:BUILD_CONTRACT_SENTINEL
            $originalFailure = $env:BUILD_CONTRACT_FAILURE
            $originalPesterResult = $env:BUILD_CONTRACT_RESULT
            $originalExecuteFixture = $env:BUILD_CONTRACT_EXECUTE_TEST_FIXTURE
            try {
                $env:PSModulePath = (
                    (Join-Path $FixtureRoot 'modules') + [System.IO.Path]::PathSeparator +
                    $originalModulePath
                )
                $env:BUILD_CONTRACT_LOG = $logPath
                $env:BUILD_CONTRACT_SENTINEL = $sentinelPath
                $env:BUILD_CONTRACT_FAILURE = $null
                $env:BUILD_CONTRACT_RESULT = $PesterResult
                $env:BUILD_CONTRACT_EXECUTE_TEST_FIXTURE = '1'
                $output = @(
                    & $powerShellPath -NoProfile -NonInteractive `
                        -ExecutionPolicy Bypass `
                        -File (Join-Path $FixtureRoot 'build.ps1') @Arguments 2>&1
                )
                $exitCode = $LASTEXITCODE
            }
            finally {
                $env:PSModulePath = $originalModulePath
                $env:BUILD_CONTRACT_LOG = $originalLogPath
                $env:BUILD_CONTRACT_SENTINEL = $originalSentinelPath
                $env:BUILD_CONTRACT_FAILURE = $originalFailure
                $env:BUILD_CONTRACT_RESULT = $originalPesterResult
                $env:BUILD_CONTRACT_EXECUTE_TEST_FIXTURE = $originalExecuteFixture
            }
            $records = @()
            if ([System.IO.File]::Exists($logPath)) {
                $records = @(
                    Get-Content -LiteralPath $logPath |
                        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
                        ForEach-Object { $_ | ConvertFrom-Json }
                )
            }
            [pscustomobject]@{
                ExitCode = $exitCode
                Output = $output
                Records = $records
                SentinelPath = $sentinelPath
            }
        }
    }
    It 'accepts exactly the six public tasks and rejects retired task names' {
        $taskParameter = (Get-Command -Name $buildPath).Parameters['Task']
        $validateSet = @(
            $taskParameter.Attributes |
                Where-Object {
                    $_ -is [System.Management.Automation.ValidateSetAttribute]
                }
        )
        $validateSet.Count | Should -Be 1

        $expectedTasks = @(
            'Bootstrap'
            'Validate'
            'Analyze'
            'Test'
            'CheckFormat'
            'ValidateRewrite'
        )
        $actualTasks = @($validateSet[0].ValidValues)
        ($actualTasks -join '|') | Should -BeExactly ($expectedTasks -join '|')
        @($actualTasks).Count | Should -Be 6
        foreach ($retiredTask in @('ValidateStyle', 'ValidateMaps', 'ValidateManifests')) {
            $actualTasks | Should -Not -Contain $retiredTask
        }
    }

    It (
        'invokes Validate with every inventory, manifest, parser, reference, and ' +
        'migration check without executing scripts'
    ) `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Validate
        $result = Invoke-BuildContractFixture -FixtureRoot $fixture
        $scriptFiles = @(
            Get-ChildItem -LiteralPath (Join-Path $fixture 'scripts/runtime') `
                -Filter '*.ps1' -File |
                Sort-Object -Property Name
        )
        $pathMap = Import-PowerShellDataFile -LiteralPath (
            Join-Path $fixture 'evidence/foundation/PathMap.psd1'
        )
        $inventoryChecks = @(
            $result.Records | Where-Object Command -eq 'Get-DeploymentScript'
        )
        $manifestChecks = @(
            $result.Records |
                Where-Object Command -eq 'Test-ScriptManifest' |
                Sort-Object -Property Path
        )
        $transitionChecks = @(
            $result.Records |
                Where-Object Command -eq 'Test-ManifestStatusTransition'
        )
        $referenceChecks = @(
            $result.Records |
                Where-Object Command -eq 'Get-UnresolvedRepositoryReference'
        )

        $result.ExitCode | Should -Be 0
        ($result.Output -join "`n") | Should -Match 'Validated 271 deployment scripts and manifests'
        (Test-Path -LiteralPath $result.SentinelPath) | Should -BeFalse
        $scriptFiles.Count | Should -Be 271
        @(
            $scriptFiles | Where-Object {
                (Get-Content -LiteralPath $_.FullName -Raw) -notmatch 'BUILD_CONTRACT_SENTINEL'
            }
        ).Count | Should -Be 0
        @($pathMap.Paths).Count | Should -Be 271
        $inventoryChecks.Count | Should -Be 1
        $inventoryChecks[0].Root | Should -Be (Join-Path $fixture 'scripts')
        $manifestChecks.Count | Should -Be 271
        $transitionChecks.Count | Should -Be 271
        $referenceChecks.Count | Should -Be 1
        $referenceChecks[0].Root | Should -Be $fixture
        $mapInvocation = @(
            $result.Records |
                Where-Object {
                    $_.Command -eq 'Invoke-Pester' -and $null -eq $_.Configuration
                }
        )
        $mapInvocation.Count | Should -Be 1
        ($result.Output -join "`n") | Should -Match `
            'Path-map and symbol-map validation passed\.'
        ($result.Output -join "`n") | Should -Match `
            'Manifest generation passed 271 byte-identical checks\.'
        $mapInvocation[0].Path | Should -Be (
            Join-Path $fixture 'tests/Repository.Tests.ps1'
        )
        @($mapInvocation[0].Tag) | Should -Be @('FoundationMapCurrentTree')
        $result.Records.Count | Should -Be 545

        for ($index = 0; $index -lt 271; $index++) {
            $number = $index + 1
            $name = 'Script{0:D3}.ps1' -f $number
            $scriptFiles[$index].Name | Should -Be $name
            $pathMap.Paths[$index].NewPath | Should -Be "runtime/$name"
            $manifestChecks[$index].Path | Should -Be (
                Join-Path $fixture "scripts/runtime/$([System.IO.Path]::ChangeExtension($name, '.psd1'))"
            )
            $manifestChecks[$index].SchemaPath | Should -Be (
                Join-Path $fixture 'standards/ManifestSchema.psd1'
            )
            $transitionChecks[$index].Before | Should -Be 'Covered'
            $transitionChecks[$index].After | Should -Be 'Covered'
        }
    }
    It 'keeps Validate independent of baseline Git blobs in an archive-like tree' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Validate
        Set-Content -LiteralPath (Join-Path $fixture 'tools/New-FoundationSymbolMap.ps1') `
            -Value @'
Add-Content -LiteralPath $env:BUILD_CONTRACT_SENTINEL -Value 'baseline-generator'
throw 'Baseline Git blob is unavailable in this archive-like fixture.'
'@ -Encoding utf8
        Set-Content -LiteralPath (Join-Path $fixture 'tests/Repository.Tests.ps1') `
            -Value @'
param([string[]] $Tag)
if (@($Tag) -contains 'FoundationMap' -or @($Tag) -contains 'FoundationMapBaseline') {
    & (Join-Path $PSScriptRoot '../tools/New-FoundationSymbolMap.ps1')
}
'@ -Encoding utf8

        $result = Invoke-BuildContractFixture -FixtureRoot $fixture
        $mapInvocation = @(
            $result.Records |
                Where-Object {
                    $_.Command -eq 'Invoke-Pester' -and $null -eq $_.Configuration
                }
        )

        $result.ExitCode | Should -Be 0
        (Test-Path -LiteralPath $result.SentinelPath) | Should -BeFalse
        $mapInvocation.Count | Should -Be 1
        @($mapInvocation[0].Tag) | Should -Be @('FoundationMapCurrentTree')
    }

    It 'rejects an internally matching 270-entry deployment inventory' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Validate
        $removedScript = Join-Path $fixture 'scripts/runtime/Script271.ps1'
        $removedManifest = Join-Path $fixture 'scripts/runtime/Script271.psd1'
        Remove-Item -LiteralPath $removedScript, $removedManifest

        $pathMapPath = Join-Path $fixture 'evidence/foundation/PathMap.psd1'
        $pathMap = (Get-Content -LiteralPath $pathMapPath -Raw).Replace(
            ",`n@{ NewPath = 'runtime/Script271.ps1' }",
            ''
        )
        Set-Content -LiteralPath $pathMapPath -Value $pathMap -Encoding utf8

        $scriptFiles = @(
            Get-ChildItem -LiteralPath (Join-Path $fixture 'scripts/runtime') `
                -Filter '*.ps1' -File
        )
        $manifestFiles = @(
            Get-ChildItem -LiteralPath (Join-Path $fixture 'scripts/runtime') `
                -Filter '*.psd1' -File
        )
        $pathMap = Import-PowerShellDataFile -LiteralPath $pathMapPath
        $scriptFiles.Count | Should -Be 270
        $manifestFiles.Count | Should -Be 270
        @($pathMap.Paths).Count | Should -Be 270

        $result = Invoke-BuildContractFixture -FixtureRoot $fixture

        $result.ExitCode | Should -Not -Be 0
        ($result.Output -join "`n") | Should -Match `
            'Expected 271 deployment scripts, found 270\.'
    }

    It 'rejects an inventory whose destination path map does not match' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Validate
        $pathMapPath = Join-Path $fixture 'evidence/foundation/PathMap.psd1'
        $pathMap = (Get-Content -LiteralPath $pathMapPath -Raw).Replace(
            'runtime/Script271.ps1',
            'runtime/Unexpected.ps1'
        )
        Set-Content -LiteralPath $pathMapPath -Value $pathMap -Encoding utf8
        $result = Invoke-BuildContractFixture -FixtureRoot $fixture

        $result.ExitCode | Should -Not -Be 0
        ($result.Output -join "`n") | Should -Match `
            'Current deployment inventory does not match the destination path map\.'
    }

    It 'rejects a deployment script with a missing manifest' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Validate
        Remove-Item -LiteralPath (Join-Path $fixture 'scripts/runtime/Script271.psd1')
        $result = Invoke-BuildContractFixture -FixtureRoot $fixture

        $result.ExitCode | Should -Not -Be 0
        ($result.Output -join "`n") | Should -Match `
            'Manifest validation failed:[\s\S]*Script271\.ps1 is missing its[\s\S]*manifest'
    }

    It 'rejects an invalid deployment manifest' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Validate
        $catalogPath = Join-Path $fixture 'tools/RepositoryCatalog.psm1'
        $catalog = (Get-Content -LiteralPath $catalogPath -Raw).Replace(
            '        Valid = $true',
            '        Valid = ($Path -notlike ''*Script001.psd1'')'
        ).Replace(
            '        Errors = @()',
            '        Errors = if ($Path -like ''*Script001.psd1'') { @(''controlled invalid manifest'') } else { @() }'
        )
        Set-Content -LiteralPath $catalogPath -Value $catalog -Encoding utf8
        $result = Invoke-BuildContractFixture -FixtureRoot $fixture

        $result.ExitCode | Should -Not -Be 0
        ($result.Output -join "`n") | Should -Match `
            'Manifest validation failed:[\s\S]*Script001\.ps1:[\s\S]*controlled'
    }

    It 'rejects a deployment script with a PowerShell parser error' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Validate
        Set-Content -LiteralPath (Join-Path $fixture 'scripts/runtime/Script271.ps1') `
            -Value 'if (' -Encoding utf8
        $result = Invoke-BuildContractFixture -FixtureRoot $fixture

        $result.ExitCode | Should -Not -Be 0
        ($result.Output -join "`n") | Should -Match `
            'PowerShell parsing failed: .*Script271\.ps1:'
    }

    It 'rejects an invalid migration transition from the catalog validator' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Validate
        $catalogPath = Join-Path $fixture 'tools/RepositoryCatalog.psm1'
        $catalog = (Get-Content -LiteralPath $catalogPath -Raw).Replace(
            '    $true',
            '    $false'
        )
        Set-Content -LiteralPath $catalogPath -Value $catalog -Encoding utf8
        $result = Invoke-BuildContractFixture -FixtureRoot $fixture

        $result.ExitCode | Should -Not -Be 0
        ($result.Output -join "`n") | Should -Match `
            'Manifest validation failed:[\s\S]*has an invalid migration state\.'
    }

    It 'rejects unresolved repository references from the catalog validator' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Validate
        $catalogPath = Join-Path $fixture 'tools/RepositoryCatalog.psm1'
        $catalog = (Get-Content -LiteralPath $catalogPath -Raw).Replace(
            "    Write-CatalogContractLog 'Get-UnresolvedRepositoryReference' @{ Root = `$Root }`n    @()`n}",
            (
                "    Write-CatalogContractLog 'Get-UnresolvedRepositoryReference' @{ " +
                "Root = `$Root }`n    [pscustomobject]@{ Markdown = 'controlled.md'; " +
                "Target = './controlled-target' }`n}"
            )
        )
        Set-Content -LiteralPath $catalogPath -Value $catalog -Encoding utf8
        $result = Invoke-BuildContractFixture -FixtureRoot $fixture

        $result.ExitCode | Should -Not -Be 0
        ($result.Output -join "`n") | Should -Match `
            'Unresolved repository references: controlled\.md: \./controlled-target'
    }

    It 'runs ValidateRewrite through the supplied rewrite-equivalence gate' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route ValidateRewrite
        $pathMapPath = Join-Path $fixture 'evidence/foundation/PathMap.psd1'
        $symbolMapPath = Join-Path $fixture 'evidence/foundation/SymbolRenames.psd1'
        $reportPath = Join-Path $fixture 'evidence/foundation/RewriteReport.json'
        $baseRevision = 'a' * 40
        $result = Invoke-BuildContractFixture `
            -FixtureRoot $fixture `
            -Arguments @(
            '-Task'
            'ValidateRewrite'
            '-BaseRevision'
            $baseRevision
            '-PathMap'
            $pathMapPath
            '-SymbolMap'
            $symbolMapPath
            '-ReportPath'
            $reportPath
        )
        $mapInvocations = @(
            $result.Records |
                Where-Object {
                    $_.Command -eq 'Invoke-Pester' -and $null -eq $_.Configuration
                }
        )
        $rewriteInvocations = @(
            $result.Records | Where-Object Command -eq 'Test-PowerShellRewrite'
        )

        $result.ExitCode | Should -Be 0
        $mapInvocations.Count | Should -Be 0
        $rewriteInvocations.Count | Should -Be 1
        $rewriteInvocations[0].BaseRevision | Should -Be $baseRevision
        $rewriteInvocations[0].PathMap | Should -Be $pathMapPath
        $rewriteInvocations[0].SymbolMap | Should -Be $symbolMapPath
        $rewriteInvocations[0].ReportPath | Should -Be $reportPath
    }
    It 'fails every Pester-bearing route when Result is non-success despite zero failed tests' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        foreach ($route in @(
                @{ Name = 'Validate'; Arguments = @('-Task', 'Validate') }
                @{ Name = 'Test'; Arguments = @('-Task', 'Test') }
                @{ Name = 'CheckFormat'; Arguments = @('-Task', 'CheckFormat') }
            )) {
            $fixture = New-BuildContractFixture -Route $route.Name
            $result = Invoke-BuildContractFixture `
                -FixtureRoot $fixture `
                -Arguments $route.Arguments `
                -PesterResult 'Failed'

            $result.ExitCode | Should -Not -Be 0
            ($result.Output -join "`n") | Should -Match `
                "non-success result 'Failed'"
        }
    }

    It 'invokes Analyze with recursive analysis and repository settings' -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Analyze
        $result = Invoke-BuildContractFixture `
            -FixtureRoot $fixture `
            -Arguments @('-Task', 'Analyze')
        $analysis = @($result.Records | Where-Object Command -eq 'Invoke-ScriptAnalyzer')

        $result.ExitCode | Should -Be 0
        $analysis.Count | Should -Be 1
        $analysis[0].Path | Should -Be $fixture
        $analysis[0].Recurse | Should -BeTrue
        $analysis[0].Settings | Should -Be (Join-Path $fixture 'PSScriptAnalyzerSettings.psd1')
    }

    It 'invokes Test with Pester configuration and Covered command coverage' -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route Test
        $result = Invoke-BuildContractFixture `
            -FixtureRoot $fixture `
            -Arguments @('-Task', 'Test')
        $testInvocation = @(
            $result.Records |
                Where-Object { $_.Command -eq 'Invoke-Pester' -and $null -ne $_.Configuration }
        )

        $result.ExitCode | Should -Be 0
        $testInvocation.Count | Should -Be 1
        $testInvocation[0].Configuration.RunPath | Should -Be (Join-Path $fixture 'tests')
        $testInvocation[0].Configuration.RunExit | Should -BeFalse
        $testInvocation[0].Configuration.RunPassThru | Should -BeTrue
        $testInvocation[0].Configuration.CoverageEnabled | Should -BeTrue
        @($testInvocation[0].Configuration.CoveragePath).Count | Should -Be 1
        @($testInvocation[0].Configuration.CoveragePath)[0] |
            Should -Be (Join-Path $fixture 'scripts/runtime/Script001.ps1')
    }

    It 'invokes CheckFormat as verification and leaves fixture bytes unchanged' -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route CheckFormat
        $selectedFiles = @(
            (Join-Path $fixture 'build.ps1'),
            (Join-Path $fixture 'tools/RequiredModules.psd1'),
            (Join-Path $fixture 'PSScriptAnalyzerSettings.psd1'),
            (Join-Path $fixture 'tests/Repository.Tests.ps1'),
            (Join-Path $fixture 'modules/Pester/Pester.psm1')
        )
        $before = @(
            Get-FileHash -Algorithm SHA256 -LiteralPath $selectedFiles |
                ForEach-Object { "$($_.Path):$($_.Hash)" }
        )
        $files = Get-ChildItem -LiteralPath $fixture -Recurse -File
        $files = @($files | Sort-Object -Property FullName)
        $beforeTree = @(
            foreach ($file in $files) {
                $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName
                "$($file.FullName):$($hash.Hash)"
            }
        )
        $result = Invoke-BuildContractFixture `
            -FixtureRoot $fixture `
            -Arguments @('-Task', 'CheckFormat')
        $after = @(
            Get-FileHash -Algorithm SHA256 -LiteralPath $selectedFiles |
                ForEach-Object { "$($_.Path):$($_.Hash)" }
        )
        $files = Get-ChildItem -LiteralPath $fixture -Recurse -File
        $files = @($files | Sort-Object -Property FullName)
        $afterTree = @(
            foreach ($file in $files) {
                $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName
                "$($file.FullName):$($hash.Hash)"
            }
        )
        $formatInvocation = @(
            $result.Records |
                Where-Object { $_.Command -eq 'Invoke-Pester' -and $null -eq $_.Configuration }
        )

        $result.ExitCode | Should -Be 0
        $formatInvocation.Count | Should -Be 1
        $formatInvocation[0].Path | Should -Be (Join-Path $fixture 'tests/Repository.Tests.ps1')
        @($formatInvocation[0].Tag) | Should -Be @('FoundationStyle')
        $formatInvocation[0].Output | Should -Be 'Detailed'
        $formatInvocation[0].PassThru | Should -BeTrue
        ($after -join "`n") | Should -Be ($before -join "`n")
        ($afterTree -join "`n") | Should -Be ($beforeTree -join "`n")
    }

    It 'propagates a failed CheckFormat result from a mutated disposable command fixture' `
        -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT -and
        $null -eq (Get-Command pwsh -ErrorAction SilentlyContinue))
    ) {
        $fixture = New-BuildContractFixture -Route CheckFormat
        $pesterPath = Join-Path $fixture 'modules/Pester/Pester.psm1'
        $mutated = (Get-Content -LiteralPath $pesterPath -Raw).Replace(
            '$failedCount = if ($env:BUILD_CONTRACT_FAILURE -eq ''1'') { 1 } else { 0 }',
            '$failedCount = 1'
        )
        Set-Content -LiteralPath $pesterPath -Value $mutated -Encoding utf8
        $result = Invoke-BuildContractFixture `
            -FixtureRoot $fixture `
            -Arguments @('-Task', 'CheckFormat')

        $result.ExitCode | Should -Not -Be 0
        ($result.Output -join "`n") | Should -Match 'Formatting verification reported 1 failed tests'
    }

    It 'retries only a publisher mismatch without forcing a module overwrite' {
        $fixture = Join-Path $TestDrive 'BootstrapFixture.ps1'
        $buildLiteral = $buildPath.Replace("'", "''")
        @"
`$ErrorActionPreference = 'Stop'
`$global:InstallCalls = @()
function Get-Module {
    param([string] `$Name, [switch] `$ListAvailable)
    [pscustomobject] @{
        Name = `$Name
        Version = [version] '3.4.0'
    }
}
function Install-Module {
    param(
        [string] `$Name,
        [string] `$RequiredVersion,
        [string] `$Repository,
        [string] `$Scope,
        [switch] `$Force,
        [switch] `$AllowClobber,
        [switch] `$SkipPublisherCheck
    )
    `$global:InstallCalls += [pscustomobject] @{
        Name = `$Name
        RequiredVersion = `$RequiredVersion
        Repository = `$Repository
        Scope = `$Scope
        Force = `$Force.IsPresent
        AllowClobber = `$AllowClobber.IsPresent
        SkipPublisherCheck = `$SkipPublisherCheck.IsPresent
    }
    if (-not `$SkipPublisherCheck) {
        throw 'PublishersMismatch: built-in publisher differs from requested module.'
    }
}
& '$buildLiteral' -Task Bootstrap
`$global:InstallCalls | ConvertTo-Json -Compress
"@ | Set-Content -LiteralPath $fixture -Encoding utf8

        $output = @(
            & $powerShellPath -NoProfile -NonInteractive `
                -ExecutionPolicy Bypass -File $fixture
        )
        $exitCode = $LASTEXITCODE

        $exitCode | Should -Be 0
        $calls = @($output -join '' | ConvertFrom-Json)
        $calls.Count | Should -Be 4
        @($calls | Where-Object SkipPublisherCheck).Count | Should -Be 2
        @($calls | Where-Object Force).Count | Should -Be 0
        @($calls | Where-Object { $_.Scope -ne 'CurrentUser' }).Count |
            Should -Be 0
        @($calls | Where-Object { $_.RequiredVersion -notin @('5.7.1', '1.25.0') }).Count |
            Should -Be 0
    }

    It 'preloads CimCmdlets for a fresh ValidateRewrite process' -Skip:(
        ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT -and
        -not [System.IO.File]::Exists($windowsPowerShellPath)) -or
        [Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT
    ) {
        $baseRevision = (Get-Content `
                -LiteralPath (Join-Path $repositoryRoot 'evidence/rewrites/scripts-directory/BaseRevision.txt') `
                -Raw).Trim()
        $reportPath = Join-Path $TestDrive 'fresh-rewrite-report.json'
        $output = @(
            & $windowsPowerShellPath -NoProfile -NonInteractive `
                -ExecutionPolicy Bypass -File $buildPath `
                -Task ValidateRewrite `
                -BaseRevision $baseRevision `
                -PathMap (Join-Path $repositoryRoot 'evidence/rewrites/scripts-directory/PathMap.psd1') `
                -SymbolMap (Join-Path $repositoryRoot 'evidence/rewrites/scripts-directory/SymbolRenames.psd1') `
                -ReportPath $reportPath
        )
        $exitCode = $LASTEXITCODE
        $report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json

        $exitCode | Should -Be 0
        $report.Passed | Should -BeTrue
        @($report.Rows).Count | Should -Be 271
        @($report.Failures).Count | Should -Be 0
        ($output -join "`n") | Should -Not -Match 'deployment'
    }
}
