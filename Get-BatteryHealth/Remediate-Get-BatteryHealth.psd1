@{
    SchemaVersion = '1.0'
    Id = '1d23cbb7-a544-556d-836b-f5e8ecbf6741'
    Identity = @{
        PackageName = 'Get-BatteryHealth'
        ScriptName = 'Remediate-Get-BatteryHealth'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Generates a battery health report and applies power optimizations.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Get-BatteryHealth/remediation_generate-batteryreport.ps1'
        Counterpart = 'Get-BatteryHealth/Detect-Get-BatteryHealth.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-Date'
            'Join-Path'
            'New-Item'
            'Out-Null'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'powercfg'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'ReportDirectory'
            Required = $false
            Secret = $false
            Description = 'Directory used for generated battery reports.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Get BatteryHealth state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'File'
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
