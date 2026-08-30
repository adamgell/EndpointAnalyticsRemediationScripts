@{
    SchemaVersion = '1.0'
    Id = '87c98998-980e-5c3f-90d1-fda8240315ec'
    Identity = @{
        PackageName = 'Install-WindowsUpdates'
        ScriptName = 'Detect-Install-WindowsUpdates'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if there are pending Windows updates.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Install-WindowsUpdates/detection_Install-WindowsUpdatesDetection.ps1'
        Counterpart = 'Install-WindowsUpdates/Remediate-Install-WindowsUpdates.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'ForEach-Object'
            'New-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Native'
            'Network'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
