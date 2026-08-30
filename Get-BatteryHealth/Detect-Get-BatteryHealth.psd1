@{
    SchemaVersion = '1.0'
    Id = 'd469c8f0-f5d4-591d-9bd4-ec6170e0daea'
    Identity = @{
        PackageName = 'Get-BatteryHealth'
        ScriptName = 'Detect-Get-BatteryHealth'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects battery health status on laptops.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Get-BatteryHealth/detection_detect-batteryhealth.ps1'
        Counterpart = 'Get-BatteryHealth/Remediate-Get-BatteryHealth.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @(
            'AllSupported'
        )
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-CimInstance'
            'Get-Content'
            'Remove-Item'
            'Test-Path'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @(
            'powercfg'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'MinHealthPercent'
            Required = $false
            Secret = $false
            Description = 'Minimum accepted battery health percentage.'
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
        Categories = @(
            'File'
            'Process'
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
