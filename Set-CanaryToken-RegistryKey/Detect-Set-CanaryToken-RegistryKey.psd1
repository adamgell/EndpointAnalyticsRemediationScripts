@{
    SchemaVersion = '1.0'
    Id = 'd7ffc763-4958-5a74-b443-c8c3bc7d96f0'
    Identity = @{
        PackageName = 'Set-CanaryToken-RegistryKey'
        ScriptName = 'Detect-Set-CanaryToken-RegistryKey'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if canary Token is in Registry.'
        Authors = @(
            'Tom Coleman'
        )
        Source = 'Set-CanaryToken-RegistryKey/detection_DetectCanaryToken.ps1'
        Counterpart = 'Set-CanaryToken-RegistryKey/Remediate-Set-CanaryToken-RegistryKey.ps1'
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
        Executables = @(
            'wmic.exe'
        )
        Policies = @(
            'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wmic.exe'
        )
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'RegistryPath'
            Required = $true
            Secret = $false
            Description = 'Canary-token registry path.'
        }
        @{
            Name = 'RegistryName'
            Required = $true
            Secret = $false
            Description = 'Canary-token registry value name.'
        }
        @{
            Name = 'RegistryValue'
            Required = $true
            Secret = $false
            Description = 'Canary-token registry value.'
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
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
