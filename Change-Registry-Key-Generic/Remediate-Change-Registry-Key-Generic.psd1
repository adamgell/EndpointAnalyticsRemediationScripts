@{
    SchemaVersion = '1.0'
    Id = 'ef1eb7a3-6822-5b68-88cc-3db7d8a02225'
    Identity = @{
        PackageName = 'Change-Registry-Key-Generic'
        ScriptName = 'Remediate-Change-Registry-Key-Generic'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Sets the configured registry value to the required value.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Jannik Reinhard'
        )
        Source = 'Change-Registry-Key-Generic/remediation_remediate-regkey.ps1'
        Counterpart = 'Change-Registry-Key-Generic/Detect-Change-Registry-Key-Generic.ps1'
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
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'RegistryPath'
            Required = $true
            Secret = $false
            Description = 'Target registry path.'
        }
        @{
            Name = 'RegistryName'
            Required = $true
            Secret = $false
            Description = 'Target registry value name.'
        }
        @{
            Name = 'RegistryValue'
            Required = $true
            Secret = $false
            Description = 'Required registry value.'
        }
        @{
            Name = 'RegistryType'
            Required = $true
            Secret = $false
            Description = 'Target registry value type.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact =
        'The script changes the Change Registry Key Generic state and can briefly affect users or services.'
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
