BeforeAll {
    Import-Module "$PSScriptRoot/../tools/RepositoryCatalog.psm1" -Force

    $repoRoot = (Resolve-Path "$PSScriptRoot/..").Path
    $schemaPath = Join-Path $repoRoot 'standards/ManifestSchema.psd1'
    $pathMapPath = Join-Path $repoRoot 'evidence/foundation/PathMap.psd1'
    $metadataPath = Join-Path $repoRoot 'standards/FoundationPackages.psd1'
    $generatorPath = Join-Path $repoRoot 'tools/New-ScriptManifest.ps1'
    $powerShellPath = (Get-Process -Id $PID).Path
    $scripts = @(Get-DeploymentScript -Root $repoRoot)
    $pathMap = Import-PowerShellDataFile -Path $pathMapPath
    $metadata = Import-PowerShellDataFile -Path $metadataPath
    $infrastructureDirectories = @(
        '.git', '.github', '.superpowers', 'assets', 'docs', 'evidence', 'standards', 'tests', 'tools'
    )
    $manifestFiles = @(
        Get-ChildItem -LiteralPath $repoRoot -Directory |
            Where-Object Name -NotIn $infrastructureDirectories |
            ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -File -Filter '*.psd1' }
    )

    function Get-RepositoryRelativePath {
        param([Parameter(Mandatory)] [string] $Path)

        return $Path.Substring($repoRoot.Length + 1).Replace('\', '/')
    }

    function Invoke-TestManifestGenerator {
        param(
            [Parameter(Mandatory)] [string] $TestPathMap,
            [Parameter(Mandatory)] [string] $TestMetadata,
            [Parameter(Mandatory)] [string] $OutputRoot
        )

        $output = @(
            & $powerShellPath -NoProfile -File $generatorPath `
                -PathMap $TestPathMap `
                -Metadata $TestMetadata `
                -Schema $schemaPath `
                -OutputRoot $OutputRoot 2>&1
        )

        return [pscustomobject]@{
            ExitCode = $LASTEXITCODE
            Output = $output -join [Environment]::NewLine
        }
    }

    function New-GeneratorFixture {
        param(
            [Parameter(Mandatory)] [string] $Root,
            [Parameter(Mandatory)] [string] $MarkerPath
        )

        $catalogRoot = Join-Path $Root 'catalog'
        $scriptDirectory = Join-Path $catalogRoot 'Fixture'
        New-Item -ItemType Directory -Path $scriptDirectory -Force | Out-Null
        $scriptPath = Join-Path $scriptDirectory 'Detect-Fixture.ps1'
        $escapedMarkerPath = $MarkerPath.Replace("'", "''")
        Set-Content -LiteralPath $scriptPath -Encoding utf8 -Value @(
            "Set-Content -LiteralPath '$escapedMarkerPath' -Value 'executed'"
            "throw 'Catalog script executed.'"
        )

        $fixturePathMap = Join-Path $Root 'PathMap.psd1'
        Set-Content -LiteralPath $fixturePathMap -Encoding utf8 -Value @'
@{
    Paths = @(
        @{ BasePath = 'Legacy/detection_fixture.ps1'; NewPath = 'Fixture/Detect-Fixture.ps1' }
    )
}
'@

        $fixtureMetadata = Join-Path $Root 'FoundationPackages.psd1'
        Set-Content -LiteralPath $fixtureMetadata -Encoding utf8 -Value @'
@{
    ManifestNamespaceGuid = 'f5d90edc-dac2-5918-8a09-77c7387264ab'
    ScriptMetadata = @{
        'Fixture/Detect-Fixture.ps1' = @{
            Version = '1.2.3'
            Description = 'Collects fixture state without executing the catalog script.'
            Authors = @('Repository Test')
            Runtime = @{
                RunAs = 'System'
                RequiresElevation = $false
                SignatureCheck = 'NotRequired'
                SupportedWindows = @('AllSupported')
                Reboot = 'None'
            }
            Behavior = @{ DetectionMode = 'Inventory' }
            Dependencies = @{
                Modules = @()
                Cmdlets = @('Get-Item')
                Executables = @()
                Policies = @()
                Endpoints = @()
            }
            Configuration = @()
            Risk = @{
                Level = 'Low'
                Destructive = $false
                UserImpact = 'None'
                Rollback = 'Not required; detection only.'
                DataHandling = 'Collects fixture state only.'
            }
            Test = @{
                Categories = @('File')
                IntegrationLevel = 'None'
                RequiresIntunePilot = $false
                RequiresInteractiveUser = $false
            }
        }
    }
}
'@

        return [pscustomobject]@{
            CatalogRoot = $catalogRoot
            PathMap = $fixturePathMap
            Metadata = $fixtureMetadata
            ScriptPath = $scriptPath
        }
    }

    function ConvertTo-ScriptMetadataIndex {
        param([Parameter(Mandatory)] [object] $Records)

        $recordSize = 10
        $index = @{}
        $recordIndex = 0
        foreach ($record in @($Records)) {
            $values = @($record)
            if ($values.Count -ne $recordSize) {
                throw "ScriptMetadata record $recordIndex must contain exactly $recordSize values."
            }

            $path = [string] $values[0]
            if ([string]::IsNullOrWhiteSpace($path) -or $index.ContainsKey($path)) {
                throw "ScriptMetadata path at record $recordIndex is empty or duplicated."
            }

            $index[$path] = @{
                Version = $values[1]
                Description = $values[2]
                Authors = @($values[3])
                Runtime = @($values[4])
                Behavior = $values[5]
                Dependencies = @($values[6])
                Configuration = @($values[7])
                Risk = @($values[8])
                Test = @($values[9])
            }
            $recordIndex++
        }

        return $index
    }

    $scriptMetadataRecords = ConvertFrom-Json -InputObject $metadata.ScriptMetadataJson
    $scriptMetadataByPath = ConvertTo-ScriptMetadataIndex -Records $scriptMetadataRecords
}

Describe 'Script manifest schema' {
    It 'accepts native boolean and numeric scalar types' {
        $result = Test-ScriptManifest `
            -Path "$PSScriptRoot/fixtures/manifests/ValidDetection.psd1" `
            -SchemaPath $schemaPath

        $result.Valid | Should -BeTrue
        $result.Errors | Should -BeNullOrEmpty
    }

    It 'rejects quoted booleans and coverage values' {
        $result = Test-ScriptManifest `
            -Path "$PSScriptRoot/fixtures/manifests/InvalidQuotedScalars.psd1" `
            -SchemaPath $schemaPath

        $result.Valid | Should -BeFalse
        $result.Errors | Should -Contain 'Runtime.RequiresElevation must be Boolean.'
        $result.Errors | Should -Contain 'Risk.Destructive must be Boolean.'
        $result.Errors | Should -Contain 'Test.CoverageFloor must be numeric.'
    }

    It 'enforces one-way migration status transitions' -ForEach @(
        @{ Before = 'PendingMigration'; After = 'PendingMigration'; Allowed = $true }
        @{ Before = 'PendingMigration'; After = 'Covered'; Allowed = $true }
        @{ Before = 'Covered'; After = 'Covered'; Allowed = $true }
        @{ Before = 'Covered'; After = 'PendingMigration'; Allowed = $false }
    ) {
        Test-ManifestStatusTransition -Before $Before -After $After |
            Should -Be $Allowed
    }
}

Describe 'Catalog script manifests' {
    It 'has one sidecar for every script and no missing, orphan, or duplicate rows' {
        $expectedPaths = @(
            $scripts |
                ForEach-Object {
                    Get-RepositoryRelativePath -Path ([IO.Path]::ChangeExtension($_.FullName, '.psd1'))
                } |
                Sort-Object
        )
        $actualPaths = @(
            $manifestFiles |
                ForEach-Object { Get-RepositoryRelativePath -Path $_.FullName } |
                Sort-Object
        )

        $scripts.Count | Should -Be 271
        $manifestFiles.Count | Should -Be 271
        @($expectedPaths | Group-Object | Where-Object Count -ne 1) | Should -BeNullOrEmpty
        @($actualPaths | Group-Object | Where-Object Count -ne 1) | Should -BeNullOrEmpty
        @($expectedPaths | Where-Object { $_ -notin $actualPaths }) | Should -BeNullOrEmpty
        @($actualPaths | Where-Object { $_ -notin $expectedPaths }) | Should -BeNullOrEmpty
    }

    It 'validates every sidecar against ManifestSchema.psd1' {
        $manifestFiles.Count | Should -Be 271
        $invalid = foreach ($script in $scripts) {
            $path = [IO.Path]::ChangeExtension($script.FullName, '.psd1')
            if (Test-Path -LiteralPath $path) {
                $result = Test-ScriptManifest -Path $path -SchemaPath $schemaPath
                if (-not $result.Valid) {
                    [pscustomobject]@{ Path = $path; Errors = $result.Errors -join '; ' }
                }
            }
        }

        $invalid | Should -BeNullOrEmpty
    }

    It 'uses native scalar types in every sidecar' {
        $manifestFiles.Count | Should -Be 271
        foreach ($manifestFile in $manifestFiles) {
            $manifest = Import-PowerShellDataFile -Path $manifestFile.FullName
            $manifest.Runtime.RequiresElevation | Should -BeOfType [bool]
            $manifest.Risk.Destructive | Should -BeOfType [bool]
            $manifest.Test.CoverageFloor | Should -BeOfType [double]
            $manifest.Test.RequiresIntunePilot | Should -BeOfType [bool]
            $manifest.Test.RequiresInteractiveUser | Should -BeOfType [bool]
            foreach ($setting in @($manifest.Configuration)) {
                $setting.Required | Should -BeOfType [bool]
                $setting.Secret | Should -BeOfType [bool]
            }
        }
    }

    It 'uses exact mapped scenarios, roles, sources, and counterparts' {
        $manifestFiles.Count | Should -Be 271
        $rowsByPackage = $pathMap.Paths | Group-Object { Split-Path $_.NewPath -Parent } -AsHashTable -AsString

        foreach ($row in $pathMap.Paths) {
            $manifestPath = Join-Path $repoRoot ([IO.Path]::ChangeExtension($row.NewPath, '.psd1'))
            if (-not (Test-Path -LiteralPath $manifestPath)) {
                continue
            }

            $manifest = Import-PowerShellDataFile -Path $manifestPath
            $packageName = Split-Path $row.NewPath -Parent
            $scriptName = [IO.Path]::GetFileNameWithoutExtension($row.NewPath)
            $expectedRole = if ($scriptName.StartsWith('Detect-', [StringComparison]::Ordinal)) {
                'Detection'
            } else {
                'Remediation'
            }
            $packageRows = @($rowsByPackage[$packageName])
            $expectedCounterpart = if ($packageRows.Count -eq 2) {
                @($packageRows | Where-Object NewPath -ne $row.NewPath)[0].NewPath
            } else {
                ''
            }

            $manifest.Identity.PackageName | Should -BeExactly $packageName
            $manifest.Identity.ScriptName | Should -BeExactly $scriptName
            $manifest.Identity.Role | Should -BeExactly $expectedRole
            $manifest.Identity.Source | Should -BeExactly $row.BasePath
            $manifest.Identity.Counterpart | Should -BeExactly $expectedCounterpart
        }
    }

    It 'uses symmetric pairs and exactly seven detection-only scenarios' {
        $manifestFiles.Count | Should -Be 271
        $standalone = [System.Collections.Generic.List[string]]::new()
        $paired = 0

        foreach ($script in $scripts) {
            $manifestPath = [IO.Path]::ChangeExtension($script.FullName, '.psd1')
            if (-not (Test-Path -LiteralPath $manifestPath)) {
                continue
            }

            $manifest = Import-PowerShellDataFile -Path $manifestPath
            if ([string]::IsNullOrEmpty($manifest.Identity.Counterpart)) {
                $manifest.Identity.Role | Should -BeExactly 'Detection'
                $standalone.Add($manifest.Identity.PackageName)
                continue
            }

            $paired++
            $counterpartPath = Join-Path $repoRoot $manifest.Identity.Counterpart
            Test-Path -LiteralPath $counterpartPath | Should -BeTrue
            (Split-Path $counterpartPath -Parent) | Should -BeExactly $script.DirectoryName
            $counterpartManifest = Import-PowerShellDataFile -Path (
                [IO.Path]::ChangeExtension($counterpartPath, '.psd1')
            )
            $counterpartManifest.Identity.Counterpart | Should -BeExactly (
                Get-RepositoryRelativePath -Path $script.FullName
            )
        }

        $paired | Should -Be 264
        @($standalone | Sort-Object) | Should -Be @(
            'Browser-Passwords'
            'Check-DiskHealth'
            'Disk-Repair'
            'Get-ConnectedDevices'
            'Get-WH4BEnrolledMethods'
            'Get-WH4BLastUsedMethod'
            'Run-ConnectionTest'
        )
    }

    It 'uses immutable unique IDs and stable reviewed versions' {
        $manifestFiles.Count | Should -Be 271
        $ids = [System.Collections.Generic.List[string]]::new()

        foreach ($row in $pathMap.Paths) {
            $manifestPath = Join-Path $repoRoot ([IO.Path]::ChangeExtension($row.NewPath, '.psd1'))
            if (-not (Test-Path -LiteralPath $manifestPath)) {
                continue
            }

            $manifest = Import-PowerShellDataFile -Path $manifestPath
            $ids.Add(([guid] $manifest.Id).Guid)
            $manifest.Identity.Version | Should -BeExactly $scriptMetadataByPath[$row.NewPath].Version
            $manifest.Identity.Version | Should -BeExactly '1.0.0'
        }

        $ids.Count | Should -Be 271
        @($ids | Sort-Object -Unique).Count | Should -Be 271
        $metadata.ManifestNamespaceGuid | Should -BeExactly 'f5d90edc-dac2-5918-8a09-77c7387264ab'
        (Import-PowerShellDataFile "$repoRoot/Activate-Numlock/Detect-Activate-Numlock.psd1").Id |
            Should -BeExactly 'b82ba3eb-f5f1-5aa1-87bc-8934240b8cdd'
        (Import-PowerShellDataFile "$repoRoot/Remove-New-Outlook/Detect-Remove-New-Outlook.psd1").Id |
            Should -BeExactly '433c1557-c869-5a1f-9721-4625700f2976'
        (Import-PowerShellDataFile "$repoRoot/Remove-Silverlight/Detect-Remove-Silverlight.psd1").Id |
            Should -BeExactly '4317dd12-54dc-5265-9bcf-c91e5af8757d'
        (Import-PowerShellDataFile "$repoRoot/Winget-Update-All/Remediate-Winget-Update-All.psd1").Id |
            Should -BeExactly 'f55579b6-afde-5849-80fa-422395418742'
    }

    It 'starts every existing script at PendingMigration and numeric zero coverage' {
        $manifestFiles.Count | Should -Be 271
        foreach ($manifestFile in $manifestFiles) {
            $manifest = Import-PowerShellDataFile -Path $manifestFile.FullName
            $manifest.Test.Status | Should -BeExactly 'PendingMigration'
            $manifest.Test.CoverageFloor | Should -Be 0.0
            $manifest.Test.CoverageFloor | Should -BeOfType [double]
        }
    }

    It 'stores no values for settings marked secret' {
        $manifestFiles.Count | Should -Be 271
        foreach ($manifestFile in $manifestFiles) {
            $manifest = Import-PowerShellDataFile -Path $manifestFile.FullName
            foreach ($setting in @($manifest.Configuration | Where-Object Secret)) {
                $setting.ContainsKey('Value') | Should -BeFalse
            }
        }
    }

    It 'has complete reviewed metadata with no sentinel values' {
        $scriptMetadataByPath.Count | Should -Be 271
        foreach ($row in $pathMap.Paths) {
            $record = $scriptMetadataByPath[$row.NewPath]
            $record | Should -Not -BeNullOrEmpty -Because $row.NewPath
            $record.Version | Should -Not -BeNullOrEmpty
            $record.Description | Should -Not -BeNullOrEmpty
            $record.Authors | Should -Not -BeNullOrEmpty
            $record.Runtime | Should -Not -BeNullOrEmpty
            $record.Behavior | Should -Not -BeNullOrEmpty
            $record.Dependencies | Should -Not -BeNullOrEmpty
            $null -eq $record.Configuration | Should -BeFalse
            $record.Risk | Should -Not -BeNullOrEmpty
            $record.Test | Should -Not -BeNullOrEmpty
            ($record | ConvertTo-Json -Depth 10 -Compress) |
                Should -Not -Match '(?i)<[^>]+>|\b(?:TBD|TODO|UNKNOWN|PLACEHOLDER|SENTINEL)\b'
        }
    }
}

Describe 'Deterministic manifest generation' {
    It 'generates the complete registry under Windows PowerShell 5.1' -Skip:(
        [Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT
    ) {
        $windowsPowerShellPath = Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'
        $outputRoot = Join-Path $TestDrive 'windows-powershell-5.1'
        $output = @(
            & $windowsPowerShellPath -NoProfile -NonInteractive -File $generatorPath `
                -PathMap $pathMapPath `
                -Metadata $metadataPath `
                -Schema $schemaPath `
                -OutputRoot $outputRoot 2>&1
        )

        $LASTEXITCODE | Should -Be 0 -Because ($output -join [Environment]::NewLine)
        @(Get-ChildItem -LiteralPath $outputRoot -Recurse -File -Filter '*.psd1').Count |
            Should -Be 271
    }

    It 'regenerates all 271 sidecars byte-identically' {
        Test-Path -LiteralPath $generatorPath | Should -BeTrue
        $firstRoot = Join-Path $TestDrive 'first'
        $secondRoot = Join-Path $TestDrive 'second'

        $firstRun = Invoke-TestManifestGenerator `
            -TestPathMap $pathMapPath `
            -TestMetadata $metadataPath `
            -OutputRoot $firstRoot
        $secondRun = Invoke-TestManifestGenerator `
            -TestPathMap $pathMapPath `
            -TestMetadata $metadataPath `
            -OutputRoot $secondRoot

        $firstRun.ExitCode | Should -Be 0 -Because $firstRun.Output
        $secondRun.ExitCode | Should -Be 0 -Because $secondRun.Output
        $firstFiles = @(Get-ChildItem -LiteralPath $firstRoot -Recurse -File -Filter '*.psd1')
        $secondFiles = @(Get-ChildItem -LiteralPath $secondRoot -Recurse -File -Filter '*.psd1')
        $firstFiles.Count | Should -Be 271
        $secondFiles.Count | Should -Be 271

        $firstRelativePaths = @(
            $firstFiles |
                ForEach-Object { $_.FullName.Substring($firstRoot.Length + 1).Replace('\', '/') } |
                Sort-Object
        )
        $secondRelativePaths = @(
            $secondFiles |
                ForEach-Object { $_.FullName.Substring($secondRoot.Length + 1).Replace('\', '/') } |
                Sort-Object
        )
        $firstRelativePaths | Should -Be $secondRelativePaths

        foreach ($relativePath in $firstRelativePaths) {
            $firstHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $firstRoot $relativePath)).Hash
            $secondHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $secondRoot $relativePath)).Hash
            $catalogHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $repoRoot $relativePath)).Hash
            $firstHash | Should -BeExactly $catalogHash -Because "$relativePath differs from the curated sidecar"
            $firstHash | Should -BeExactly $secondHash -Because $relativePath
        }
    }

    It 'does not execute catalog scripts while generating manifests' {
        $fixtureRoot = Join-Path $TestDrive 'no-execution'
        $markerPath = Join-Path $fixtureRoot 'catalog-executed.txt'
        $fixture = New-GeneratorFixture -Root $fixtureRoot -MarkerPath $markerPath

        $run = Invoke-TestManifestGenerator `
            -TestPathMap $fixture.PathMap `
            -TestMetadata $fixture.Metadata `
            -OutputRoot $fixture.CatalogRoot

        $run.ExitCode | Should -Be 0 -Because $run.Output
        Test-Path -LiteralPath $markerPath | Should -BeFalse
        Test-Path -LiteralPath (
            [IO.Path]::ChangeExtension($fixture.ScriptPath, '.psd1')
        ) | Should -BeTrue
    }

    It 'exits nonzero when a mapped script has no reviewed metadata' {
        $fixtureRoot = Join-Path $TestDrive 'missing-metadata'
        New-Item -ItemType Directory -Path $fixtureRoot -Force | Out-Null
        $missingPathMap = Join-Path $fixtureRoot 'PathMap.psd1'
        Set-Content -LiteralPath $missingPathMap -Encoding utf8 -Value @'
@{
    Paths = @(
        @{ BasePath = 'Legacy/missing.ps1'; NewPath = 'Missing/Detect-Missing.ps1' }
    )
}
'@

        $run = Invoke-TestManifestGenerator `
            -TestPathMap $missingPathMap `
            -TestMetadata $metadataPath `
            -OutputRoot (Join-Path $fixtureRoot 'output')

        $run.ExitCode | Should -Not -Be 0
        $run.Output | Should -Match 'Missing/Detect-Missing\.ps1.*metadata'
    }

    It 'exits nonzero for sentinel metadata and quoted native scalars' {
        $fixtureRoot = Join-Path $TestDrive 'invalid-metadata'
        $markerPath = Join-Path $fixtureRoot 'catalog-executed.txt'
        $fixture = New-GeneratorFixture -Root $fixtureRoot -MarkerPath $markerPath
        $invalidText = Get-Content -LiteralPath $fixture.Metadata -Raw
        $invalidText = $invalidText.Replace(
            "Description = 'Collects fixture state without executing the catalog script.'",
            "Description = 'TBD'"
        ).Replace(
            'RequiresElevation = $false',
            "RequiresElevation = 'false'"
        )
        Set-Content -LiteralPath $fixture.Metadata -Encoding utf8 -Value $invalidText

        $run = Invoke-TestManifestGenerator `
            -TestPathMap $fixture.PathMap `
            -TestMetadata $fixture.Metadata `
            -OutputRoot $fixture.CatalogRoot

        $run.ExitCode | Should -Not -Be 0
        $run.Output | Should -Match 'sentinel|RequiresElevation.*Boolean'
        Test-Path -LiteralPath $markerPath | Should -BeFalse
    }
}
