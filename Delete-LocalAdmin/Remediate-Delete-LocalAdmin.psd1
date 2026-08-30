@{
    SchemaVersion = '1.0'
    Id = '6d85765e-3959-5a20-a15a-3ffbd81424c4'
    Identity = @{
        PackageName = 'Delete-LocalAdmin'
        ScriptName = 'Remediate-Delete-LocalAdmin'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Delete LocalAdmin condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Create-LocalAdmin/remediation_Delete-LocalAdminRemediation.ps1'
        Counterpart = 'Delete-LocalAdmin/Detect-Delete-LocalAdmin.ps1'
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
            'Remove-LocalUser'
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
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Delete LocalAdmin operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Native'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
