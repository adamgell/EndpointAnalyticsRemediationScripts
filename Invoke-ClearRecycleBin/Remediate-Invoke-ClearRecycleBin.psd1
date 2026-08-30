@{
    SchemaVersion = '1.0'
    Id = '972854d0-dad2-529e-a770-262b4f74e024'
    Identity = @{
        PackageName = 'Invoke-ClearRecycleBin'
        ScriptName = 'Remediate-Invoke-ClearRecycleBin'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Invoke ClearRecycleBin condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Invoke-ClearRecycleBin/remediation_Invoke-ClearRecycleBinRemedaiton.ps1'
        Counterpart = 'Invoke-ClearRecycleBin/Detect-Invoke-ClearRecycleBin.ps1'
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
            'Clear-RecycleBin'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Invoke ClearRecycleBin operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
