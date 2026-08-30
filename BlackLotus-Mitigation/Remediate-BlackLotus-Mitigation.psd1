@{
    SchemaVersion = '1.0'
    Id = 'afc9f909-69ac-5e63-bdcd-a80b40b2f407'
    Identity = @{
        PackageName = 'BlackLotus-Mitigation'
        ScriptName = 'Remediate-BlackLotus-Mitigation'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Applies BlackLotus (CVE-2023-24932) mitigation by enabling the Secure Boot revocation.'
        Authors = @('Jannik Reinhard')
        Source = 'BlackLotus-Mitigation/remediation_BlackLotus-MitigationRemediation.ps1'
        Counterpart = 'BlackLotus-Mitigation/Detect-BlackLotus-Mitigation.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'Required'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Confirm-SecureBootUEFI', 'Get-ItemProperty', 'Set-ItemProperty', 'Test-Path', 'Write-Error', 'Write-Output')
        Executables = @()
        Policies = @('HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Critical'
        Destructive = $false
        UserImpact = 'The script changes the BlackLotus Mitigation state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Registry', 'File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
