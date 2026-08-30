@{
    SchemaVersion = '1.0'
    Id = 'd15100c0-debd-5fbc-a90f-455b5e726b39'
    Identity = @{
        PackageName = 'Invoke-TeamsInstallation'
        ScriptName = 'Remediate-Invoke-TeamsInstallation'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Invoke TeamsInstallation condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Invoke-TeamsInstallation/remediation_Invoke-TeamsInstallationRemedaiton.ps1'
        Counterpart = 'Invoke-TeamsInstallation/Detect-Invoke-TeamsInstallation.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
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
            'new-object'
            'Start-Process'
        )
        Executables = @(
            'msiexec.exe'
        )
        Policies = @()
        Endpoints = @(
            'https://aka.ms/teams64bitmsi'
            'System.Net.WebClient'
        )
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Invoke TeamsInstallation state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Network'
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
