@{
    SchemaVersion = '1.0'
    Id = '1d989c91-45fa-5c16-9db9-f1a97e33de20'
    Identity = @{
        PackageName = 'Invoke-Shutdown'
        ScriptName = 'Remediate-Invoke-Shutdown'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Invoke Shutdown condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Invoke-Shutdown/remediation_Invoke-ShutdownRemedaiton.ps1'
        Counterpart = 'Invoke-Shutdown/Detect-Invoke-Shutdown.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'Required'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Add-Type')
        Executables = @('shutdown')
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'Shuts down the device, terminating user sessions and services and risking loss of unsaved work.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Ui', 'Destructive', 'Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
