@{
    SchemaVersion = '1.0'
    Id = 'fbe77220-0657-5f6a-b045-4f8ffc6a31e3'
    Identity = @{
        PackageName = 'Disable-SMBv1'
        ScriptName = 'Detect-Disable-SMBv1'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if SMBv1 is enabled.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Disable-SMBv1/detection_detect-smbv1.ps1'
        Counterpart = 'Disable-SMBv1/Remediate-Disable-SMBv1.ps1'
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
            'get-smbserverconfiguration'
            'Select-Object'
            'write-host'
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
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
