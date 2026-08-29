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
        Compare-Object -ReferenceObject @($map.Paths.BasePath) -DifferenceObject $inventory -CaseSensitive |
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
        $symbolMap = Import-PowerShellDataFile "$PSScriptRoot/../evidence/foundation/SymbolRenames.psd1"
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
            'Toast-RebootMessage/Remediate-Toast-RebootMessage.ps1|Where|Where-Object|1'
            'Toast-RebootMessage/Remediate-Toast-RebootMessage.ps1|Where|Where-Object|2'
        )
        $actual = @($symbolMap.Aliases | ForEach-Object {
            '{0}|{1}|{2}|{3}' -f $_.Path, $_.OldName, $_.NewName, $_.Occurrence
        })

        @($actual).Count | Should -Be 12
        @($symbolMap.Aliases.Path | Sort-Object -Unique).Count | Should -Be 9
        Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive |
            Should -BeNullOrEmpty
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
