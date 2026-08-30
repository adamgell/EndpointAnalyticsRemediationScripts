@{
    SchemaVersion = '1.0'
    Id = 'db8b0608-08f7-56b5-8c5b-13c187f2c758'
    Identity = @{
        PackageName = 'Set-CanaryToken-RegistryKey'
        ScriptName = 'Remediate-Set-CanaryToken-RegistryKey'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Adds a canary Token to Registry https://blog.thinkst.com/2022/09/sensitive-command-token-so-much-offense.html Go To https://www.canarytokens.org to generate your token.  This will trigger alerts in defender which you will have to tune out.'
        Authors = @('Tom Coleman')
        Source = 'Set-CanaryToken-RegistryKey/remediation_RemediateCanaryToken.ps1'
        Counterpart = 'Set-CanaryToken-RegistryKey/Detect-Set-CanaryToken-RegistryKey.ps1'
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
        Cmdlets = @('New-Item', 'New-ItemProperty', 'Out-Null', 'Test-Path')
        Executables = @('cmd.exe', 'powershell.exe', 'wmic.exe')
        Policies = @('Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wmic.exe', 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\wmic.exe', 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wmic.exe', 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\wmic.exe')
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
        @{
            Name = 'CanaryTokenDnsName'
            Required = $true
            Secret = $true
            Description = 'Unique canary-token DNS name embedded in the registry command.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Set CanaryToken RegistryKey state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
    }
    Test = @{
        Categories = @('Registry', 'File', 'Process', 'Network')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
