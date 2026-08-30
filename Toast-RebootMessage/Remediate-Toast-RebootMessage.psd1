@{
    SchemaVersion = '1.0'
    Id = 'cde9986c-1829-51ca-9ced-c8acb5c79ef9'
    Identity = @{
        PackageName = 'Toast-RebootMessage'
        ScriptName = 'Remediate-Toast-RebootMessage'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Provides a notification to the user to reboot their machine.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Toast-RebootMessage/remediation_remediate-reboot.ps1'
        Counterpart = 'Toast-RebootMessage/Detect-Toast-RebootMessage.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $false
        SignatureCheck = 'NotRequired'
        SupportedWindows = @(
            'AllSupported'
        )
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'New-Object'
            'Where-Object'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Toast RebootMessage state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Ui'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
