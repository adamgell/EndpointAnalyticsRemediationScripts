@{
    SchemaVersion = '1.0'
    Id = '17a2595f-f5ee-5ed7-a87e-11176976759a'
    Identity = @{
        PackageName = 'Get-OfficeTelemetry'
        ScriptName = 'Remediate-Get-OfficeTelemetry'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Disable O365 from sharing telemetry.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Get-OfficeTelemetry/remediation_Remediate_Office_Telemetry.ps1'
        Counterpart = 'Get-OfficeTelemetry/Detect-Get-OfficeTelemetry.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('New-Item', 'New-ItemProperty')
        Executables = @()
        Policies = @('HKCU:\Software\Policies\Microsoft\office\common\', 'HKCU:\Software\Policies\Microsoft\office\common\clienttelemetry')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'The script changes the Get OfficeTelemetry state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Registry')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
