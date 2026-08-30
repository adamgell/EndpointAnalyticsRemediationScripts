@{
    SchemaVersion = '1.0'
    Id = '32209c00-b28a-5d90-95a3-6e98f61e4258'
    Identity = @{
        PackageName = 'BlackLotus-Mitigation'
        ScriptName = 'Detect-BlackLotus-Mitigation'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if the system is vulnerable to the BlackLotus (CVE-2023-24932) Secure Boot bypass.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'BlackLotus-Mitigation/detection_BlackLotus-MitigationDetection.ps1'
        Counterpart = 'BlackLotus-Mitigation/Remediate-BlackLotus-Mitigation.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
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
            'Confirm-SecureBootUEFI'
            'Get-ItemProperty'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot'
            'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
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
