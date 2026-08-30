@{
    SchemaVersion = '1.0'
    Id = 'c529c888-1e32-5e10-85b4-e5d583f89f04'
    Identity = @{
        PackageName = 'Clear-BrowserCache'
        ScriptName = 'Remediate-Clear-BrowserCache'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Clears Chrome and Edge browser cache.'
        Authors = @('Jannik Reinhard')
        Source = 'Clear-BrowserCache/remediation_Clear-BrowserCacheRemediation.ps1'
        Counterpart = 'Clear-BrowserCache/Detect-Clear-BrowserCache.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'NotRequired'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ChildItem', 'Remove-Item', 'Test-Path', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Clear BrowserCache operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('File', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
