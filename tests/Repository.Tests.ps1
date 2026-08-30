Describe 'Foundation path map' -Tag 'FoundationMap' {
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

Describe 'Foundation path map details' -Tag 'FoundationMap' {
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
        $infrastructureDirectories = @(
            '.git', '.github', '.superpowers', 'assets', 'docs', 'evidence', 'standards', 'tests', 'tools'
        )
        $inventory = @(
            foreach ($directory in Get-ChildItem -LiteralPath $repositoryRoot -Directory) {
                if ($directory.Name -in $infrastructureDirectories) {
                    continue
                }
                foreach ($file in Get-ChildItem -LiteralPath $directory.FullName -Recurse -File) {
                    if ($file.Extension -ine '.ps1' -and -not [string]::IsNullOrEmpty($file.Extension)) {
                        continue
                    }
                    $file.FullName.Substring($repositoryRoot.Length).TrimStart('\', '/').Replace('\', '/')
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

Describe 'Foundation symbol map' -Tag 'FoundationMap' {
    BeforeAll {
        $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $symbolGenerator = Join-Path $repositoryRoot 'tools/New-FoundationSymbolMap.ps1'
        $pathMapPath = Join-Path $repositoryRoot 'evidence/foundation/PathMap.psd1'
        $pathMap = Import-PowerShellDataFile $pathMapPath
        $packageDataPath = Join-Path $repositoryRoot 'standards/FoundationPackages.psd1'
        $symbolMapPath = Join-Path $repositoryRoot 'evidence/foundation/SymbolRenames.psd1'
        $expectedSymbolMapBytes = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($symbolMapPath))
        $symbolMap = Import-PowerShellDataFile $symbolMapPath
        function Copy-FoundationSymbolGenerator {
            param([Parameter(Mandatory)] [string] $Root)

            $toolDirectory = Join-Path $Root 'tools'
            [System.IO.Directory]::CreateDirectory($toolDirectory) | Out-Null
            $fixtureGenerator = Join-Path $toolDirectory 'New-FoundationSymbolMap.ps1'
            [System.IO.File]::Copy($symbolGenerator, $fixtureGenerator, $false)
            return $fixtureGenerator
        }

        function Copy-FoundationMappedFile {
            param(
                [Parameter(Mandatory)] [string] $Root,
                [Parameter(Mandatory)] [string] $SourceRelativePath,
                [Parameter(Mandatory)] [string] $TargetRelativePath
            )

            $sourcePath = Join-Path $repositoryRoot $SourceRelativePath.Replace(
                '/',
                [System.IO.Path]::DirectorySeparatorChar
            )
            $targetPath = Join-Path $Root $TargetRelativePath.Replace(
                '/',
                [System.IO.Path]::DirectorySeparatorChar
            )
            [System.IO.Directory]::CreateDirectory(
                [System.IO.Path]::GetDirectoryName($targetPath)
            ) | Out-Null
            [System.IO.File]::Copy($sourcePath, $targetPath, $false)
            return $targetPath
        }

        function Copy-FoundationSymbolTree {
            param(
                [Parameter(Mandatory)] [string] $Root,
                [Parameter(Mandatory)]
                [ValidateSet('BasePath', 'NewPath')]
                [string] $Layout
            )

            $fixtureGenerator = Copy-FoundationSymbolGenerator -Root $Root
            foreach ($pathRow in @($pathMap.Paths)) {
                $null = Copy-FoundationMappedFile `
                    -Root $Root `
                    -SourceRelativePath ([string] $pathRow.NewPath) `
                    -TargetRelativePath ([string] $pathRow[$Layout])
            }
            return $fixtureGenerator
        }

        function Copy-FoundationSymbolTreeWithDirectoryCasing {
            param(
                [Parameter(Mandatory)] [string] $Root,
                [Parameter(Mandatory)]
                [ValidateSet('BasePath', 'NewPath')]
                [string] $Layout,
                [Parameter(Mandatory)] [string] $ApprovedDirectory,
                [Parameter(Mandatory)] [string] $ActualDirectory
            )

            $fixtureGenerator = Copy-FoundationSymbolGenerator -Root $Root
            $approvedPrefix = "$ApprovedDirectory/"
            foreach ($pathRow in @($pathMap.Paths)) {
                $targetRelativePath = [string] $pathRow[$Layout]
                if ($targetRelativePath.StartsWith(
                    $approvedPrefix,
                    [System.StringComparison]::Ordinal
                )) {
                    $targetRelativePath = $ActualDirectory + $targetRelativePath.Substring(
                        $ApprovedDirectory.Length
                    )
                }
                $null = Copy-FoundationMappedFile `
                    -Root $Root `
                    -SourceRelativePath ([string] $pathRow.NewPath) `
                    -TargetRelativePath $targetRelativePath
            }
            return $fixtureGenerator
        }
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

    It 'regenerates byte-identically from a legacy-source tree' {
        $fixtureRoot = Join-Path $TestDrive 'legacy-source-tree'
        $fixtureGenerator = Copy-FoundationSymbolTree -Root $fixtureRoot -Layout BasePath
        $outputPath = Join-Path $fixtureRoot 'SymbolRenames.psd1'

        & $fixtureGenerator `
            -PathMap $pathMapPath `
            -PackageData $packageDataPath `
            -OutputPath $outputPath

        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputPath)) |
            Should -BeExactly $expectedSymbolMapBytes
    }

    It 'rejects wrong-case paths in a legacy-source tree' {
        $fixtureRoot = Join-Path $TestDrive 'wrong-case-legacy-source-tree'
        $fixtureGenerator = Copy-FoundationSymbolTreeWithDirectoryCasing `
            -Root $fixtureRoot `
            -Layout BasePath `
            -ApprovedDirectory 'Profile-cleanup' `
            -ActualDirectory 'Profile-Cleanup'
        $approvedPath = 'Profile-cleanup/detection_detect-old-profiles.ps1'
        $actualPath = 'Profile-Cleanup/detection_detect-old-profiles.ps1'

        {
            & $fixtureGenerator `
                -PathMap $pathMapPath `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $fixtureRoot 'SymbolRenames.psd1')
        } | Should -Throw "*Mapped legacy source '$approvedPath' has incorrect repository-relative casing; found '$actualPath'.*"
    }

    It 'rejects case-colliding directory siblings when the approved legacy source exists' {
        $fixtureRoot = Join-Path $TestDrive 'case-colliding-legacy-source-tree'
        $fixtureGenerator = Copy-FoundationSymbolTree -Root $fixtureRoot -Layout BasePath
        $approvedPath = 'Profile-cleanup/detection_detect-old-profiles.ps1'
        $approvedFullPath = Join-Path $fixtureRoot $approvedPath.Replace(
            '/',
            [System.IO.Path]::DirectorySeparatorChar
        )
        [System.IO.File]::Exists($approvedFullPath) | Should -BeTrue

        [System.IO.Directory]::CreateDirectory(
            (Join-Path $fixtureRoot 'Profile-Cleanup')
        ) | Out-Null
        $caseCollidingDirectories = @(
            [System.IO.Directory]::GetDirectories($fixtureRoot) |
                Where-Object {
                    [System.StringComparer]::OrdinalIgnoreCase.Equals(
                        [System.IO.Path]::GetFileName($_),
                        'Profile-Cleanup'
                    )
                }
        )
        if ($caseCollidingDirectories.Count -ne 2) {
            Set-ItResult -Skipped -Because 'The test filesystem does not preserve case-colliding names.'
            return
        }

        {
            & $fixtureGenerator `
                -PathMap $pathMapPath `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $fixtureRoot 'SymbolRenames.psd1')
        } | Should -Throw "*Repository path '$approvedPath' has multiple case-colliding matches for component 'Profile-cleanup'.*"
    }

    It 'rejects wrong-case paths in a destination-only tree' {
        $fixtureRoot = Join-Path $TestDrive 'wrong-case-destination-only-tree'
        $fixtureGenerator = Copy-FoundationSymbolTreeWithDirectoryCasing `
            -Root $fixtureRoot `
            -Layout NewPath `
            -ApprovedDirectory 'Profile-Cleanup' `
            -ActualDirectory 'Profile-cleanup'
        $approvedPath = 'Profile-Cleanup/Detect-Profile-Cleanup.ps1'
        $actualPath = 'Profile-cleanup/Detect-Profile-Cleanup.ps1'

        {
            & $fixtureGenerator `
                -PathMap $pathMapPath `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $fixtureRoot 'SymbolRenames.psd1')
        } | Should -Throw "*Mapped destination '$approvedPath' has incorrect repository-relative casing; found '$actualPath'.*"
    }

    It 'regenerates byte-identically when live command discovery is unavailable' {
        $outputPath = Join-Path $TestDrive 'without-live-discovery.psd1'

        & {
            function Get-Command {
                throw 'Live command discovery is unavailable.'
            }
            function Get-Alias {
                throw 'Live alias discovery is unavailable.'
            }

            & $symbolGenerator -PathMap $pathMapPath -PackageData $packageDataPath -OutputPath $outputPath
        }

        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputPath)) |
            Should -BeExactly $expectedSymbolMapBytes
    }

    It 'regenerates byte-identically when live command discovery is polluted' {
        $outputPath = Join-Path $TestDrive 'with-polluted-live-discovery.psd1'

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

            & $symbolGenerator -PathMap $pathMapPath -PackageData $packageDataPath -OutputPath $outputPath
        }

        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputPath)) |
            Should -BeExactly $expectedSymbolMapBytes
    }

    It 'rejects a path-map row with indistinguishable source and destination paths' {
        $fixtureRoot = Join-Path $TestDrive 'ambiguous-path-map'
        $fixtureGenerator = Copy-FoundationSymbolGenerator -Root $fixtureRoot
        $ambiguousPathMap = Join-Path $fixtureRoot 'PathMap.psd1'
        $firstPath = @($pathMap.Paths)[0]
        $pathMapContent = [System.IO.File]::ReadAllText($pathMapPath)
        $originalRow = "@{ BasePath = '$($firstPath.BasePath)'; NewPath = '$($firstPath.NewPath)' }"
        $ambiguousRow = "@{ BasePath = '$($firstPath.BasePath)'; NewPath = '$($firstPath.BasePath)' }"
        [System.IO.File]::WriteAllText(
            $ambiguousPathMap,
            $pathMapContent.Replace($originalRow, $ambiguousRow)
        )

        {
            & $fixtureGenerator `
                -PathMap $ambiguousPathMap `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $fixtureRoot 'SymbolRenames.psd1')
        } | Should -Throw "*Path map row '$($firstPath.BasePath)' uses indistinguishable source and destination paths.*"
    }

    It 'rejects an unresolved mapped file' {
        $fixtureRoot = Join-Path $TestDrive 'missing-mapped-file'
        $fixtureGenerator = Copy-FoundationSymbolGenerator -Root $fixtureRoot
        $firstPath = @($pathMap.Paths)[0]

        {
            & $fixtureGenerator `
                -PathMap $pathMapPath `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $fixtureRoot 'SymbolRenames.psd1')
        } | Should -Throw "*Neither mapped source '$($firstPath.BasePath)' nor destination '$($firstPath.NewPath)' exists.*"
    }

    It 'rejects an unexpected byte-identical dual-path state' {
        $fixtureRoot = Join-Path $TestDrive 'dual-path'
        $fixtureGenerator = Copy-FoundationSymbolGenerator -Root $fixtureRoot
        $firstPath = @($pathMap.Paths)[0]
        $null = Copy-FoundationMappedFile `
            -Root $fixtureRoot `
            -SourceRelativePath ([string] $firstPath.NewPath) `
            -TargetRelativePath ([string] $firstPath.BasePath)
        $null = Copy-FoundationMappedFile `
            -Root $fixtureRoot `
            -SourceRelativePath ([string] $firstPath.NewPath) `
            -TargetRelativePath ([string] $firstPath.NewPath)

        {
            & $fixtureGenerator `
                -PathMap $pathMapPath `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $fixtureRoot 'SymbolRenames.psd1')
        } | Should -Throw "*Mapped source '$($firstPath.BasePath)' and destination '$($firstPath.NewPath)' both exist unexpectedly.*"
    }

    It 'rejects a dual-path state with mismatched content' {
        $fixtureRoot = Join-Path $TestDrive 'mismatched-dual-path'
        $fixtureGenerator = Copy-FoundationSymbolGenerator -Root $fixtureRoot
        $firstPath = @($pathMap.Paths)[0]
        $null = Copy-FoundationMappedFile `
            -Root $fixtureRoot `
            -SourceRelativePath ([string] $firstPath.NewPath) `
            -TargetRelativePath ([string] $firstPath.BasePath)
        $destinationPath = Copy-FoundationMappedFile `
            -Root $fixtureRoot `
            -SourceRelativePath ([string] $firstPath.NewPath) `
            -TargetRelativePath ([string] $firstPath.NewPath)
        [System.IO.File]::AppendAllText($destinationPath, "`n# mismatched fixture")

        {
            & $fixtureGenerator `
                -PathMap $pathMapPath `
                -PackageData $packageDataPath `
                -OutputPath (Join-Path $fixtureRoot 'SymbolRenames.psd1')
        } | Should -Throw "*Mapped source '$($firstPath.BasePath)' and destination '$($firstPath.NewPath)' both exist with different content.*"
    }

    It 'records the five reviewed function definitions' {
        $expected = @(
            'Enable-RDP/Detect-Enable-RDP.ps1|IsMember|Test-GroupMembership'
            'Enable-RDP/Remediate-Enable-RDP.ps1|IsMember|Test-GroupMembership'
            'Get-Device-Uptime-And-Reboot/Remediate-Get-Device-Uptime-And-Reboot.ps1|Display-ToastNotification|Show-ToastNotification'
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

Describe 'Post-cutover repository inventory' -Tag 'FoundationCutover' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../tools/RepositoryCatalog.psm1" -Force
        $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $pathMap = Import-PowerShellDataFile "$repositoryRoot/evidence/foundation/PathMap.psd1"
    }

    It 'contains exactly 271 standard ps1 deployment scripts' {
        $scripts = @(Get-DeploymentScript -Root $repositoryRoot)
        $scripts.Count | Should -Be 271
        $invalid = $scripts | Where-Object {
            $_.Name -notmatch '^(Detect|Remediate)-[A-Z][A-Za-z0-9]*(?:-[A-Z0-9][A-Za-z0-9]*)*\.ps1$'
        }
        $invalid | Should -BeNullOrEmpty
    }

    It 'contains no extensionless PowerShell candidates' {
        @(Get-ExtensionlessPowerShellCandidate -Root $repositoryRoot) |
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
            -not (Test-Path -LiteralPath (Join-Path $repositoryRoot $_) -PathType Leaf)
        }
        $missing | Should -BeNullOrEmpty
    }

    It 'uses exact mapped destination casing' {
        $actualPaths = Get-DeploymentScript -Root $repositoryRoot |
            ForEach-Object {
                $_.FullName.Substring($repositoryRoot.Length).
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

            $output = @(& git -C $Root @Arguments 2>&1)
            if ($LASTEXITCODE -ne 0) {
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
