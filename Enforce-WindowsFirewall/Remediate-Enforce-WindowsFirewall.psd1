@{
    SchemaVersion = '1.0'
    Id = '8df8dd23-4c4f-5786-adc1-7dd6f3a1e3f1'
    Identity = @{
        PackageName = 'Enforce-WindowsFirewall'
        ScriptName = 'Remediate-Enforce-WindowsFirewall'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Enables Windows Firewall on all profiles.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Enforce-WindowsFirewall/remediation_enforce-windowsfirewall.ps1'
        Counterpart = 'Enforce-WindowsFirewall/Detect-Enforce-WindowsFirewall.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Set-NetFirewallProfile'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Enforce WindowsFirewall state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Network'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
