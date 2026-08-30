@{
    SchemaVersion = '1.0'
    Id = '0ab9ab5d-6424-5ea2-972c-4c21698376a7'
    Identity = @{
        PackageName = 'Change-MultipleRegistryKeys'
        ScriptName = 'Remediate-Change-MultipleRegistryKeys'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Creates the registry keys defined below.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Marius Wyss'
        )
        Source = 'Change-MultipleRegistryKeys/remediation_Change-MultipleRegistryKeysRemediaton.ps1'
        Counterpart = 'Change-MultipleRegistryKeys/Detect-Change-MultipleRegistryKeys.ps1'
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
            'Get-ItemProperty'
            'New-Item'
            'New-ItemProperty'
            'Out-Null'
            'Remove-ItemProperty'
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
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Change MultipleRegistryKeys operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
