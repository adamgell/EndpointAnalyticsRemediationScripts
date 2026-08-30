@{
    SchemaVersion = '1.0'
    Id = 'b05a3433-eaa0-5020-a4d0-ddad057436db'
    Identity = @{
        PackageName = 'Reset-PrintSpooler'
        ScriptName = 'Remediate-Reset-PrintSpooler'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Resets the Print Spooler service and clears stuck print jobs.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-PrintSpooler/remediation_reset-printspooler.ps1'
        Counterpart = 'Reset-PrintSpooler/Detect-Reset-PrintSpooler.ps1'
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
            'Start-Sleep'
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
        UserImpact = 'The Reset PrintSpooler operation can remove data, software, accounts, or configuration.'
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
