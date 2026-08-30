@{
    SchemaVersion = '1.0'
    Id = '6bd178fa-2457-593d-a696-b484680b036b'
    Identity = @{
        PackageName = 'VPN-Split-Tunnel'
        ScriptName = 'Remediate-VPN-Split-Tunnel'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Disables split tunneling on all VPN connections.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Detect-VPNSplitTunnel/remediation_disable-vpnsplittunnel.ps1'
        Counterpart = 'VPN-Split-Tunnel/Detect-VPN-Split-Tunnel.ps1'
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
            'Get-VpnConnection'
            'Set-VpnConnection'
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
        UserImpact = 'The script changes the VPN Split Tunnel state and can briefly affect users or services.'
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
