@{
    SchemaVersion = '1.0'
    Id = '11dabb5f-81b0-5756-b87e-a762c67ede8f'
    Identity = @{
        PackageName = 'Invoke-CurrentUserLoggedOff'
        ScriptName = 'Remediate-Invoke-CurrentUserLoggedOff'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Invoke CurrentUserLoggedOff condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Invoke-CurrentUserLoggedOff/remediation_Get-CurrentUserLoggedOffRemedaiton.ps1'
        Counterpart = 'Invoke-CurrentUserLoggedOff/Detect-Invoke-CurrentUserLoggedOff.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
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
            'Add-Type'
        )
        Executables = @(
            'shutdown'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Invoke CurrentUserLoggedOff operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Ui'
            'Destructive'
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
