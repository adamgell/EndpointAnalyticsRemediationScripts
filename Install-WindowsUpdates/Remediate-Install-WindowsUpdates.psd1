@{
    SchemaVersion = '1.0'
    Id = 'd906b9e9-9361-5a34-a90c-9c7717e77c6b'
    Identity = @{
        PackageName = 'Install-WindowsUpdates'
        ScriptName = 'Remediate-Install-WindowsUpdates'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Installs all pending Windows updates.'
        Authors = @('Jannik Reinhard')
        Source = 'Install-WindowsUpdates/remediation_Install-WindowsUpdatesRemediation.ps1'
        Counterpart = 'Install-WindowsUpdates/Detect-Install-WindowsUpdates.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'Possible'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('New-Object', 'Out-Null', 'Write-Error', 'Write-Output')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $false
        UserImpact = 'The script changes the Install WindowsUpdates state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Network', 'Native', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
