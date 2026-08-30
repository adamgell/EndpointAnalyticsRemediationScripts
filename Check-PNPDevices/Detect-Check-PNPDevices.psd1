@{
    SchemaVersion = '1.0'
    Id = '3ec67de1-69af-5d10-bf50-db9f34df44db'
    Identity = @{
        PackageName = 'Check-PNPDevices'
        ScriptName = 'Detect-Check-PNPDevices'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Check PNPDevices condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Marius Wyss'
        )
        Source = 'Check-PNPDevices/detection_Check-PNPDevicesDetection.ps1'
        Counterpart = 'Check-PNPDevices/Remediate-Check-PNPDevices.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-PnpDevice'
            'Where-Object'
            'Write-Host'
            'Write-Verbose'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'ClassFilterExclude'
            Required = $false
            Secret = $false
            Description = 'Device classes excluded from remediation.'
        }
        @{
            Name = 'ClassFilterInclude'
            Required = $false
            Secret = $false
            Description = 'Device classes included in remediation.'
        }
        @{
            Name = 'DeviceIdFilterExclude'
            Required = $false
            Secret = $false
            Description = 'Device identifiers excluded from remediation.'
        }
        @{
            Name = 'DeviceIdFilterInclude'
            Required = $false
            Secret = $false
            Description = 'Device identifiers included in remediation.'
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
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
