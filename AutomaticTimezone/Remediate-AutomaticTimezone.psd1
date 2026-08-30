@{
    SchemaVersion = '1.0'
    Id = '08818964-04c9-53cc-98a1-0c04df48dedc'
    Identity = @{
        PackageName = 'AutomaticTimezone'
        ScriptName = 'Remediate-AutomaticTimezone'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Sets up Automatic Timezone and Time Sync.'
        Authors = @(
            'Adam Gell'
        )
        Source = 'AutomaticTimezone/remediation_remediate-automatictimezone.ps1'
        Counterpart = 'AutomaticTimezone/Detect-AutomaticTimezone.ps1'
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
            'New-ItemProperty'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
            'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate'
        )
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'RegistryPathLocation'
            Required = $true
            Secret = $false
            Description = 'Location-consent registry path.'
        }
        @{
            Name = 'RegistryNameLocation'
            Required = $true
            Secret = $false
            Description = 'Location-consent registry value name.'
        }
        @{
            Name = 'RegistryValueLocation'
            Required = $true
            Secret = $false
            Description = 'Required location-consent registry value.'
        }
        @{
            Name = 'RegistryPathTimeZone'
            Required = $true
            Secret = $false
            Description = 'Automatic-time-zone service registry path.'
        }
        @{
            Name = 'RegistryNameTimeZone'
            Required = $true
            Secret = $false
            Description = 'Automatic-time-zone service value name.'
        }
        @{
            Name = 'RegistryValueTimeZone'
            Required = $true
            Secret = $false
            Description = 'Required automatic-time-zone service value.'
        }
        @{
            Name = 'RegistryTypeLocation'
            Required = $true
            Secret = $false
            Description = 'Location-consent registry value type.'
        }
        @{
            Name = 'RegistryTypeTimeZone'
            Required = $true
            Secret = $false
            Description = 'Automatic-time-zone service value type.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the AutomaticTimezone state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Registry'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
