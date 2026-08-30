@{
    SchemaVersion = '1.0'
    Id = '826eb830-b46b-51fd-9cbf-f45c91f5bafe'
    Identity = @{
        PackageName = 'Enforce-BitLocker'
        ScriptName = 'Remediate-Enforce-BitLocker'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Enables BitLocker on the OS drive with TPM protector.'
        Authors = @('Jannik Reinhard')
        Source = 'Enforce-BitLocker/remediation_enforce-bitlocker.ps1'
        Counterpart = 'Enforce-BitLocker/Detect-Enforce-BitLocker.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'Possible'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Add-BitLockerKeyProtector', 'Enable-BitLocker', 'Get-BitLockerVolume', 'Get-Tpm', 'Write-Error', 'Write-Output')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Critical'
        Destructive = $false
        UserImpact = 'The script changes the Enforce BitLocker state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
