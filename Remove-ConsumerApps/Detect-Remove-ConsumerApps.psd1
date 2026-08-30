@{
    SchemaVersion = '1.0'
    Id = '7d3fa53d-93d6-50a4-9333-fe6fd148ca4f'
    Identity = @{
        PackageName = 'Remove-ConsumerApps'
        ScriptName = 'Detect-Remove-ConsumerApps'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Remove ConsumerApps condition.'
        Authors = @(
            'Marius Wyss'
        )
        Source = 'Remove-ConsumerApps/detection_Remove-ConsumerAppsDetection.ps1'
        Counterpart = 'Remove-ConsumerApps/Remediate-Remove-ConsumerApps.ps1'
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
            'Get-AppxPackage'
            'Where-Object'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'ConsumerApps'
            Required = $false
            Secret = $false
            Description = 'Map of removable consumer Appx package names and display names.'
        }
    )
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Appx'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
