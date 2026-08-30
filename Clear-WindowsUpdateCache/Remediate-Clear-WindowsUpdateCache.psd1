@{
    SchemaVersion = '1.0'
    Id = 'f9919b24-e983-5b47-b9ed-eee214d4ebcb'
    Identity = @{
        PackageName = 'Clear-WindowsUpdateCache'
        ScriptName = 'Remediate-Clear-WindowsUpdateCache'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Clears the Windows Update download cache.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Clear-WindowsUpdateCache/remediation_clear-windowsupdatecache.ps1'
        Counterpart = 'Clear-WindowsUpdateCache/Detect-Clear-WindowsUpdateCache.ps1'
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
            'Remove-Item'
            'Start-Service'
            'Stop-Service'
            'Test-Path'
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
        UserImpact = 'The Clear WindowsUpdateCache operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Service'
            'File'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
