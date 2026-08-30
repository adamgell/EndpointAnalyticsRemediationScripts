@{
    SchemaVersion = '1.0'
    Id = '781c87d8-ee1b-5685-a204-be965af79196'
    Identity = @{
        PackageName = 'Disable-Coinstaller'
        ScriptName = 'Remediate-Disable-Coinstaller'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Disables device coinstallers through the configured registry policy.'
        Authors = @('Adam Gell')
        Source = 'Disable-Coinstaller/remediation_remediate-coinstaller.ps1'
        Counterpart = 'Disable-Coinstaller/Detect-Disable-Coinstaller.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('New-ItemProperty')
        Executables = @()
        Policies = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer')
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'RegistryPath'
            Required = $true
            Secret = $false
            Description = 'Device-installer policy registry path.'
        }
        @{
            Name = 'RegistryName'
            Required = $true
            Secret = $false
            Description = 'Device-installer policy value name.'
        }
        @{
            Name = 'RegistryValue'
            Required = $true
            Secret = $false
            Description = 'Required device-installer policy value.'
        }
        @{
            Name = 'RegistryType'
            Required = $true
            Secret = $false
            Description = 'Device-installer policy registry value type.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Disable Coinstaller state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
