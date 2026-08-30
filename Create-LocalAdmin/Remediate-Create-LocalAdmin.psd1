@{
    SchemaVersion = '1.0'
    Id = '18be7f31-3895-5ff5-862d-2634b0a0d8f4'
    Identity = @{
        PackageName = 'Create-LocalAdmin'
        ScriptName = 'Remediate-Create-LocalAdmin'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Create LocalAdmin condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Create-LocalAdmin/remediation_Create-LocalAdminRemediation.ps1'
        Counterpart = 'Create-LocalAdmin/Detect-Create-LocalAdmin.ps1'
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
            'New-LocalUser'
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
        @{
            Name = 'LocalAdminPassword'
            Required = $true
            Secret = $true
            Description = 'Password assigned to the local administrator account.'
        }
    )
    Risk = @{
        Level = 'Critical'
        Destructive = $false
        UserImpact = 'The script changes the Create LocalAdmin state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
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
