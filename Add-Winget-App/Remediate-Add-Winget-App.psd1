@{
    SchemaVersion = '1.0'
    Id = '9fb8965b-9ffb-5515-ab22-d99cd0bbe951'
    Identity = @{
        PackageName = 'Add-Winget-App'
        ScriptName = 'Remediate-Add-Winget-App'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Installs app via Winget.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Add-Winget-App/remediation_remediate-app.ps1'
        Counterpart = 'Add-Winget-App/Detect-Add-Winget-App.ps1'
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
            'out-null'
            'Resolve-Path'
        )
        Executables = @(
            'winget.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'AppId'
            Required = $true
            Secret = $false
            Description = 'Winget package identifier to detect or install.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Add Winget App state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
