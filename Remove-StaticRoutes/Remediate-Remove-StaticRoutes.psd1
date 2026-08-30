@{
    SchemaVersion = '1.0'
    Id = 'f77a2457-da01-5637-9c9b-50fa6f8b84c1'
    Identity = @{
        PackageName = 'Remove-StaticRoutes'
        ScriptName = 'Remediate-Remove-StaticRoutes'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Removes orphaned static routes with unreachable gateways.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Remove-StaticRoutes/remediation_remove-staticroutes.ps1'
        Counterpart = 'Remove-StaticRoutes/Detect-Remove-StaticRoutes.ps1'
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
            'Get-NetRoute'
            'Remove-NetRoute'
            'Test-Connection'
            'Where-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Remove StaticRoutes operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Network'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
