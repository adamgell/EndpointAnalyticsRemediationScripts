@{
    SchemaVersion = '1.0'
    Id = '1e78bc98-37bc-5fde-b449-b52fefc33d02'
    Identity = @{
        PackageName = 'BlockAADWorkplaceJoin'
        ScriptName = 'Detect-BlockAADWorkplaceJoin'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the BlockAADWorkplaceJoin condition.'
        Authors = @(
            'EndpointAnalyticsRemediationScripts contributors'
        )
        Source = 'BlockAADWorkplaceJoin/detection_Detection-BlockAADWorkplaceJoin.ps1'
        Counterpart = 'BlockAADWorkplaceJoin/Remediate-BlockAADWorkplaceJoin.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $false
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
            'Get-ItemProperty'
            'Test-Path'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin'
        )
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
