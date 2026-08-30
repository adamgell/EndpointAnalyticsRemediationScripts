@{
    SchemaVersion = '1.0'
    Id = 'ccec8078-b38a-5a73-9c73-4568f34137b1'
    Identity = @{
        PackageName = 'Set-DefaultBrowser'
        ScriptName = 'Remediate-Set-DefaultBrowser'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Sets Microsoft Edge as the default browser via policy.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Set-DefaultBrowser/remediation_set-defaultbrowser.ps1'
        Counterpart = 'Set-DefaultBrowser/Detect-Set-DefaultBrowser.ps1'
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
            'New-Item'
            'New-ItemProperty'
            'Out-File'
            'Out-Null'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Set DefaultBrowser state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
