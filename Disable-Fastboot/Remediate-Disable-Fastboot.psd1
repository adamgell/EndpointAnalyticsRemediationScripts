@{
    SchemaVersion = '1.0'
    Id = 'bb457613-7ac4-5ae8-bbfe-fd08be1109f5'
    Identity = @{
        PackageName = 'Disable-Fastboot'
        ScriptName = 'Remediate-Disable-Fastboot'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Disables Fastboot via registry key.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Disable-Fastboot/remediation_remediate-fastboot.ps1'
        Counterpart = 'Disable-Fastboot/Detect-Disable-Fastboot.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('New-ItemProperty')
        Executables = @()
        Policies = @('HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Disable Fastboot state and can briefly affect users or services.'
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
