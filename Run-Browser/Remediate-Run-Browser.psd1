@{
    SchemaVersion = '1.0'
    Id = '40fee5b2-01de-5c91-bab9-8b6aa2938721'
    Identity = @{
        PackageName = 'Run-Browser'
        ScriptName = 'Remediate-Run-Browser'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Run Browser condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Run-Browser/remediation_Get-TemplateRemedaiton.ps1'
        Counterpart = 'Run-Browser/Detect-Run-Browser.ps1'
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
            'Start-Process'
        )
        Executables = @()
        Policies = @()
        Endpoints = @(
            'https://www.bing.com'
        )
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Run Browser state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Network'
            'Ui'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
