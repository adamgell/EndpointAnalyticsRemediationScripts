@{
    SchemaVersion = '1.0'
    Id = '5760ab70-b9a4-5e73-bb21-c10ce15afd7a'
    Identity = @{
        PackageName = 'AutomaticTimezone'
        ScriptName = 'Detect-AutomaticTimezone'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Sets up Automatic Timezone and Time Sync.'
        Authors = @(
            'Adam Gell'
        )
        Source = 'AutomaticTimezone/detection_detect-automatictimezone.ps1'
        Counterpart = 'AutomaticTimezone/Remediate-AutomaticTimezone.ps1'
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
            'Get-ItemProperty'
            'Select-Object'
            'Write-Output'
            'Write-Warning'
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
            'Registry'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
