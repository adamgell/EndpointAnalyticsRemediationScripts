@{
    SchemaVersion = '1.0'
    Id = '3b470c66-7098-57ba-b2a7-1d94ce907dc2'
    Identity = @{
        PackageName = 'Reset-Windows-Update'
        ScriptName = 'Remediate-Reset-Windows-Update'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Reset Windows Update condition.'
        Authors = @('EndpointAnalyticsRemediationScripts contributors')
        Source = 'Reset Windows Update/remediation_ResetWindowsUpdateRemediation.ps1'
        Counterpart = 'Reset-Windows-Update/Detect-Reset-Windows-Update.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-Service', 'Remove-Item', 'Rename-Item', 'Start-Service', 'Stop-Service', 'Test-Path', 'Where-Object')
        Executables = @('wuauclt.exe')
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Reset Windows Update operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('Service', 'File', 'Native', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
