@{
    SchemaVersion = '1.0'
    Id = 'f0087b1a-e70f-5b76-96ec-825d0644df75'
    Identity = @{
        PackageName = 'Reset-NotificationCenter'
        ScriptName = 'Remediate-Reset-NotificationCenter'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Resets the Windows Notification Center database.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-NotificationCenter/remediation_reset-notificationcenter.ps1'
        Counterpart = 'Reset-NotificationCenter/Detect-Reset-NotificationCenter.ps1'
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
            'Get-ChildItem'
            'Join-Path'
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
        Level = 'Medium'
        Destructive = $true
        UserImpact = 'The Reset NotificationCenter operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'File'
            'Service'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
