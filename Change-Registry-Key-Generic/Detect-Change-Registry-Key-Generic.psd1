@{
    SchemaVersion = '1.0'
    Id = '5a3596d4-56a6-573d-b0e3-0b15bc534053'
    Identity = @{
        PackageName = 'Change-Registry-Key-Generic'
        ScriptName = 'Detect-Change-Registry-Key-Generic'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects whether the configured registry value matches the required value.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Jannik Reinhard')
        Source = 'Change-Registry-Key-Generic/detection_detect-regkey.ps1'
        Counterpart = 'Change-Registry-Key-Generic/Remediate-Change-Registry-Key-Generic.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ItemProperty', 'Select-Object', 'Write-Output', 'Write-Warning')
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
    )
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
