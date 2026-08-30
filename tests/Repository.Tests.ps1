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
        Import-Module "$PSScriptRoot/../tools/RepositoryCatalog.psm1" -Force
        $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $symbolGenerator = Join-Path $repositoryRoot 'tools/New-FoundationSymbolMap.ps1'
        $pathMapPath = Join-Path $repositoryRoot 'evidence/foundation/PathMap.psd1'
        $pathMap = Import-PowerShellDataFile $pathMapPath
        $packageDataPath = Join-Path $repositoryRoot 'standards/FoundationPackages.psd1'
        $symbolMapPath = Join-Path $repositoryRoot 'evidence/foundation/SymbolRenames.psd1'
        $expectedSymbolMapBytes = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($symbolMapPath))
        $symbolMap = Import-PowerShellDataFile $symbolMapPath
        $baseRevision = (
            Get-Content "$repositoryRoot/evidence/foundation/BaseRevision.txt" -Raw
        ).Trim()
        $gitContext = Resolve-FoundationRepositoryGitContext -RepositoryRoot $repositoryRoot
        $gitDirectory = $gitContext.GitDirectory
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
                [Parameter(Mandatory)] [string] $TargetRelativePath,
                [switch] $FromBaseline
            )

            $targetPath = Join-Path $Root $TargetRelativePath.Replace(
                '/',
                [System.IO.Path]::DirectorySeparatorChar
            )
            [System.IO.Directory]::CreateDirectory(
                [System.IO.Path]::GetDirectoryName($targetPath)
            ) | Out-Null
            if ($FromBaseline) {
                $gitOutput = @(& git `
                        "--git-dir=$gitDirectory" `
                        show `
                        "${baseRevision}:$SourceRelativePath" 2>&1)
                if ($LASTEXITCODE -ne 0) {
                    throw "Unable to read baseline '$SourceRelativePath': $($gitOutput -join [Environment]::NewLine)"
                }
                $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
                [System.IO.File]::WriteAllLines($targetPath, $gitOutput, $utf8NoBom)
            }
            else {
                $sourcePath = Join-Path $repositoryRoot $SourceRelativePath.Replace(
                    '/',
                    [System.IO.Path]::DirectorySeparatorChar
                )
                [System.IO.File]::Copy($sourcePath, $targetPath, $false)
            }
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
                $sourceRelativePath = if ($Layout -eq 'BasePath') {
                    [string] $pathRow.BasePath
                }
                else {
                    [string] $pathRow.NewPath
                }
                $null = Copy-FoundationMappedFile `
                    -Root $Root `
                    -SourceRelativePath $sourceRelativePath `
                    -TargetRelativePath ([string] $pathRow[$Layout]) `
                    -FromBaseline:($Layout -eq 'BasePath')
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
                $sourceRelativePath = if ($Layout -eq 'BasePath') {
                    [string] $pathRow.BasePath
                }
                else {
                    [string] $pathRow.NewPath
                }
                $null = Copy-FoundationMappedFile `
                    -Root $Root `
                    -SourceRelativePath $sourceRelativePath `
                    -TargetRelativePath $targetRelativePath `
                    -FromBaseline:($Layout -eq 'BasePath')
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
        } | Should -Throw (
            "*Mapped legacy source '$approvedPath' has incorrect repository-relative casing; " +
            "found '$actualPath'.*"
        )
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
        } | Should -Throw (
            "*Repository path '$approvedPath' has multiple case-colliding matches " +
            "for component 'Profile-cleanup'.*"
        )
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
        } | Should -Throw (
            "*Mapped destination '$approvedPath' has incorrect repository-relative casing; " +
            "found '$actualPath'.*"
        )
    }

    It 'regenerates byte-identically when live command discovery is unavailable' {
        $fixtureRoot = Join-Path $TestDrive 'without-live-discovery'
        $fixtureGenerator = Copy-FoundationSymbolTree -Root $fixtureRoot -Layout BasePath
        $outputPath = Join-Path $fixtureRoot 'SymbolRenames.psd1'
        & {
            function Get-Command {
                throw 'Live command discovery is unavailable.'
            }
            function Get-Alias {
                throw 'Live alias discovery is unavailable.'
            }

            & $fixtureGenerator -PathMap $pathMapPath -PackageData $packageDataPath -OutputPath $outputPath
        }

        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($outputPath)) |
            Should -BeExactly $expectedSymbolMapBytes
    }

    It 'regenerates byte-identically when live command discovery is polluted' {
        $fixtureRoot = Join-Path $TestDrive 'with-polluted-live-discovery'
        $fixtureGenerator = Copy-FoundationSymbolTree -Root $fixtureRoot -Layout BasePath
        $outputPath = Join-Path $fixtureRoot 'SymbolRenames.psd1'
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

            & $fixtureGenerator -PathMap $pathMapPath -PackageData $packageDataPath -OutputPath $outputPath
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
        } | Should -Throw (
            "*Neither mapped source '$($firstPath.BasePath)' nor destination " +
            "'$($firstPath.NewPath)' exists.*"
        )
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
        } | Should -Throw (
            "*Mapped source '$($firstPath.BasePath)' and destination " +
            "'$($firstPath.NewPath)' both exist unexpectedly.*"
        )
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
        } | Should -Throw (
            "*Mapped source '$($firstPath.BasePath)' and destination " +
            "'$($firstPath.NewPath)' both exist with different content.*"
        )
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

Describe 'Foundation static style' -Tag 'FoundationStyle' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../tools/RepositoryCatalog.psm1" -Force
        $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
        $packageData = Import-PowerShellDataFile "$repositoryRoot/standards/FoundationPackages.psd1"
        $styleExclusions = Get-Content `
            -LiteralPath "$repositoryRoot/evidence/foundation/StaticAnalysisExclusions.json" `
            -Raw |
            ConvertFrom-Json
        $approvedLongLineDigest = 'd43eae67fa2231aeebc5895e9e1418ca025361dca6c4643ca8c50e990c282abe'
        $scriptFiles = @(Get-DeploymentScript -Root $repositoryRoot)
        $trackedPowerShellPaths = @(
            Get-FoundationTrackedPowerShellPath -RepositoryRoot $repositoryRoot
        )
        $trackedPowerShellFiles = @(
            foreach ($relativePath in $trackedPowerShellPaths) {
                $fullPath = Join-Path $repositoryRoot $relativePath
                if (-not [System.IO.File]::Exists($fullPath)) {
                    throw "Tracked PowerShell file '$relativePath' does not exist."
                }
                [pscustomobject]@{
                    File = Get-Item -LiteralPath $fullPath
                    Path = $relativePath
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
            $relativePath = $scriptFile.FullName.Substring($repositoryRoot.Length).
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
