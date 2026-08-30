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
        $packageDataPath = Join-Path $repositoryRoot 'standards/FoundationPackages.psd1'
        $symbolMapPath = Join-Path $repositoryRoot 'evidence/foundation/SymbolRenames.psd1'
        $expectedSymbolMapBytes = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($symbolMapPath))
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
