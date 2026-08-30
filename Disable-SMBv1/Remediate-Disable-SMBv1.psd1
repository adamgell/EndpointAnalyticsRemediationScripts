@{
    SchemaVersion = '1.0'
    Id = '0e295f12-60cd-546e-a767-6698cfe893d8'
    Identity = @{
        PackageName = 'Disable-SMBv1'
        ScriptName = 'Remediate-Disable-SMBv1'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Disables SMBv1 via registry key.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Disable-SMBv1/remediation_remediate-smbv1.ps1'
        Counterpart = 'Disable-SMBv1/Detect-Disable-SMBv1.ps1'
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
        Cmdlets = @('Set-SmbServerConfiguration')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Disable SMBv1 state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
