@{
    SchemaVersion = '1.0'
    Id = 'e892ce99-a16a-5a9a-9482-9ce219af33c6'
    Identity = @{
        PackageName = 'Driver-Issues'
        ScriptName = 'Remediate-Driver-Issues'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Attempts to fix driver issues by restarting problem devices.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Detect-DriverIssues/remediation_fix-driverissues.ps1'
        Counterpart = 'Driver-Issues/Detect-Driver-Issues.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
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
            'Disable-PnpDevice'
            'Enable-PnpDevice'
            'Get-PnpDevice'
            'Out-Null'
            'Start-Sleep'
            'Write-Error'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @(
            'pnputil'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Driver Issues operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Process'
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
