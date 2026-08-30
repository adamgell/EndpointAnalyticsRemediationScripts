@{
    SchemaVersion = '1.0'
    Id = '54925867-5291-5eb6-962f-c7a2bcf942d3'
    Identity = @{
        PackageName = 'Clear-FontCache'
        ScriptName = 'Remediate-Clear-FontCache'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Clears the Windows font cache.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Clear-FontCache/remediation_clear-fontcache.ps1'
        Counterpart = 'Clear-FontCache/Detect-Clear-FontCache.ps1'
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
        Reboot = 'Possible'
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
        UserImpact = 'The Clear FontCache operation can remove data, software, accounts, or configuration.'
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
