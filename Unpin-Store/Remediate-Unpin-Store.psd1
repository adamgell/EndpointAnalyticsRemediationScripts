@{
    SchemaVersion = '1.0'
    Id = '177d4a02-6453-5360-b795-7261831834bd'
    Identity = @{
        PackageName = 'Unpin-Store'
        ScriptName = 'Remediate-Unpin-Store'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Unpins the Windows Store from the taskbar.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Unpin Store/remediation_remediate-store.ps1'
        Counterpart = 'Unpin-Store/Detect-Unpin-Store.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('ForEach-Object', 'New-Object', 'Where-Object')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'The script changes the Unpin Store state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Ui', 'Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
