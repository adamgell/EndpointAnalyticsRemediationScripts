@{
    SchemaVersion = '1.0'
    Id = 'f45ce317-43d9-520c-b5b2-44880611355c'
    Identity = @{
        PackageName = 'Enforce-WindowsFirewall'
        ScriptName = 'Detect-Enforce-WindowsFirewall'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Windows Firewall is enabled on all profiles.'
        Authors = @('Jannik Reinhard')
        Source = 'Enforce-WindowsFirewall/detection_detect-windowsfirewall.ps1'
        Counterpart = 'Enforce-WindowsFirewall/Remediate-Enforce-WindowsFirewall.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-NetFirewallProfile', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Network')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
