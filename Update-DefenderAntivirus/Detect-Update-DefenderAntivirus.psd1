@{
    SchemaVersion = '1.0'
    Id = '16876f65-2b45-5cf2-837e-ed7d6d54cedd'
    Identity = @{
        PackageName = 'Update-DefenderAntivirus'
        ScriptName = 'Detect-Update-DefenderAntivirus'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Windows Defender antivirus definitions are outdated.'
        Authors = @('Jannik Reinhard')
        Source = 'Update-DefenderAntivirus/detection_Update-DefenderAntivirusDetection.ps1'
        Counterpart = 'Update-DefenderAntivirus/Remediate-Update-DefenderAntivirus.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-Date', 'Get-MpComputerStatus', 'New-TimeSpan', 'Write-Error', 'Write-Output')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'MaxDefinitionAgeDays'
            Required = $false
            Secret = $false
            Description = 'Maximum accepted Defender definition age in days.'
        }
    )
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
