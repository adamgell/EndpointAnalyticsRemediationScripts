@{
    SchemaVersion = '1.0'
    Id = '3f595976-08ab-5c6b-ab30-f571cd6186b9'
    Identity = @{
        PackageName = 'VPN-Split-Tunnel'
        ScriptName = 'Detect-VPN-Split-Tunnel'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects VPN connections configured with split tunneling.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Detect-VPNSplitTunnel/detection_detect-vpnsplittunnel.ps1'
        Counterpart = 'VPN-Split-Tunnel/Remediate-VPN-Split-Tunnel.ps1'
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
            'ForEach-Object'
            'Get-VpnConnection'
            'Where-Object'
            'Write-Output'
            'Write-Warning'
        )
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
