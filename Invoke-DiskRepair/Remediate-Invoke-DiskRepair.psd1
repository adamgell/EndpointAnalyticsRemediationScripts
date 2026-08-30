@{
    SchemaVersion = '1.0'
    Id = '5aa9b534-1302-545a-83ca-9a4167dd84db'
    Identity = @{
        PackageName = 'Invoke-DiskRepair'
        ScriptName = 'Remediate-Invoke-DiskRepair'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Invoke DiskRepair condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Invoke-DiskRepair/remediation_Get-TemplateRemedaiton.ps1'
        Counterpart = 'Invoke-DiskRepair/Detect-Invoke-DiskRepair.ps1'
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
        Reboot = 'Possible'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Repair-Volume'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Invoke DiskRepair operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Destructive'
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
