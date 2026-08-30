@{
    SchemaVersion = '1.0'
    Id = '3c8185b7-ed16-5074-a35e-693af03703fa'
    Identity = @{
        PackageName = 'Reset-OutlookProfile'
        ScriptName = 'Remediate-Reset-OutlookProfile'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Resets the Outlook profile by removing OST files.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-OutlookProfile/remediation_reset-outlookprofile.ps1'
        Counterpart = 'Reset-OutlookProfile/Detect-Reset-OutlookProfile.ps1'
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
            'ForEach-Object'
            'Get-ChildItem'
            'Get-Process'
            'Join-Path'
            'Remove-Item'
            'Start-Sleep'
            'Stop-Process'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'OUTLOOK.EXE'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Reset OutlookProfile operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Process'
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
