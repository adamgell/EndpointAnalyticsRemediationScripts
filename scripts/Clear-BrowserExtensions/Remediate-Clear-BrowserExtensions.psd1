@{
    SchemaVersion = '1.0'
    Id = '9f3f3188-504b-597b-a85e-34547b02c66b'
    Identity = @{
        PackageName = 'Clear-BrowserExtensions'
        ScriptName = 'Remediate-Clear-BrowserExtensions'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Blocks unapproved browser extensions via policy.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Clear-BrowserExtensions/remediation_clear-browserextensions.ps1'
        Counterpart = 'Clear-BrowserExtensions/Detect-Clear-BrowserExtensions.ps1'
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
            'Out-Null'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist'
            'HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallBlocklist'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $false
        UserImpact = 'The script changes the Clear BrowserExtensions state and can briefly affect users or services.'
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
