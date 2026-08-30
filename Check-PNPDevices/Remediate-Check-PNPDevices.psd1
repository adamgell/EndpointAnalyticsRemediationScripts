@{
    SchemaVersion = '1.0'
    Id = '00ec180c-956a-5795-a52e-02ba6b52fe7c'
    Identity = @{
        PackageName = 'Check-PNPDevices'
        ScriptName = 'Remediate-Check-PNPDevices'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Check PNPDevices condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Marius Wyss'
        )
        Source = 'Check-PNPDevices/remediation_Check-PNPDevicesRemediation.ps1'
        Counterpart = 'Check-PNPDevices/Detect-Check-PNPDevices.ps1'
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
            'Get-PnpDevice'
            'Out-String'
            'Where-Object'
            'Write-Host'
            'Write-Verbose'
        )
        Executables = @(
            'pnputil.exe'
        )
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
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Check PNPDevices state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Process'
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
