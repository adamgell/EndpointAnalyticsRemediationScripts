@{
    SchemaVersion = '1.0'
    Id = 'e7809f1e-9e34-5fe2-b286-71691d1cf1b2'
    Identity = @{
        PackageName = 'Enable-DarkMode'
        ScriptName = 'Remediate-Enable-DarkMode'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Enables system-wide dark mode.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Enable-DarkMode/remediation_enable-darkmode.ps1'
        Counterpart = 'Enable-DarkMode/Detect-Enable-DarkMode.ps1'
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
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Enable DarkMode state and can briefly affect users or services.'
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
