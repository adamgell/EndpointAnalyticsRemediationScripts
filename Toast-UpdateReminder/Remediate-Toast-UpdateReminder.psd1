@{
    SchemaVersion = '1.0'
    Id = 'fd7cfe82-b6c5-51be-9391-8c85e55a6f84'
    Identity = @{
        PackageName = 'Toast-UpdateReminder'
        ScriptName = 'Remediate-Toast-UpdateReminder'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Shows a toast notification reminding the user to install pending updates.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Toast-UpdateReminder/remediation_toast-updatereminder.ps1'
        Counterpart = 'Toast-UpdateReminder/Detect-Toast-UpdateReminder.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
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
            'Out-Null'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'powershell.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Toast UpdateReminder state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Process'
            'Ui'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
