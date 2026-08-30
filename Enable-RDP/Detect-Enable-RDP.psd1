@{
    SchemaVersion = '1.0'
    Id = '1ae644ff-f443-55ec-94bb-ecd68ad184fb'
    Identity = @{
        PackageName = 'Enable-RDP'
        ScriptName = 'Detect-Enable-RDP'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Enable RDP condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Enable-RDP/detection_Enable-RDPDetection.ps1'
        Counterpart = 'Enable-RDP/Remediate-Enable-RDP.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'AlwaysRemediate' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ItemProperty', 'Get-LocalGroupMember', 'Write-Host')
        Executables = @()
        Policies = @('HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\')
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
        Categories = @('Registry')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
