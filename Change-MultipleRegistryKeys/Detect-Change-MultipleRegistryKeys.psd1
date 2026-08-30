@{
    SchemaVersion = '1.0'
    Id = '6e16b756-8362-57e6-93a1-6bf681bdad64'
    Identity = @{
        PackageName = 'Change-MultipleRegistryKeys'
        ScriptName = 'Detect-Change-MultipleRegistryKeys'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Checks if the registry keys defined are set correctly.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Marius Wyss'
        )
        Source = 'Change-MultipleRegistryKeys/detection_Change-MultipleRegistryKeysDetection.ps1'
        Counterpart = 'Change-MultipleRegistryKeys/Remediate-Change-MultipleRegistryKeys.ps1'
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
            'Get-Item'
            'Get-ItemProperty'
            'Measure-Object'
            'Test-Path'
            'Write-Output'
        )
        Executables = @()
        Policies = @(
            'HKLM:\'
            'SOFTWARE\Contoso\Product'
        )
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'RegistrySettingsToValidate'
            Required = $true
            Secret = $false
            Description = 'Registry setting records to detect, create, update, or delete.'
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
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
