@{
    SchemaVersion = '1.0'
    Id = '02cb9006-ac08-5034-b5ac-3663c950cfe8'
    Identity = @{
        PackageName = 'Create-Laps-LocalAdmin'
        ScriptName = 'Remediate-Create-Laps-LocalAdmin'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Creates a local administrator with a random password before Windows LAPS manages the account.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Simon Skotheimsvik'
            'Simon'
        )
        Source = 'Create-LocalAdmin/remediation_Create-LocalAdminLAPSRemediation.ps1'
        Counterpart = 'Create-Laps-LocalAdmin/Detect-Create-Laps-LocalAdmin.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
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
            'Add-LocalGroupMember'
            'ConvertTo-SecureString'
            'ForEach-Object'
            'Get-LocalGroup'
            'New-LocalUser'
            'New-Object'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'LocalAdminName'
            Required = $true
            Secret = $false
            Description = 'Local administrator account name.'
        }
    )
    Risk = @{
        Level = 'Critical'
        Destructive = $false
        UserImpact = 'The script changes the Create Laps LocalAdmin state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
