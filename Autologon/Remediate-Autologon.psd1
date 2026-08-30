@{
    SchemaVersion = '1.0'
    Id = 'cb8ccdf5-610d-5e88-ad02-b4e9ff721eb1'
    Identity = @{
        PackageName = 'Autologon'
        ScriptName = 'Remediate-Autologon'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Configures Windows Autologon via registry. IMPORTANT: Update the username and password variables before deployment.'
        Authors = @('Jannik Reinhard')
        Source = 'Detect-Autologon/remediation_Detect-AutologonRemediation.ps1'
        Counterpart = 'Autologon/Detect-Autologon.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Set-ItemProperty', 'Write-Error', 'Write-Output')
        Executables = @()
        Policies = @('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon')
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'AutologonUser'
            Required = $true
            Secret = $false
            Description = 'Account name used for automatic sign-in.'
        }
        @{
            Name = 'AutologonDomain'
            Required = $true
            Secret = $false
            Description = 'Account domain used for automatic sign-in.'
        }
        @{
            Name = 'AutologonPassword'
            Required = $true
            Secret = $true
            Description = 'Password used for automatic sign-in.'
        }
    )
    Risk = @{
        Level = 'Critical'
        Destructive = $false
        UserImpact = 'The script changes the Autologon state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
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
