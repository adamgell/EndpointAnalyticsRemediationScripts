@{
    SchemaVersion = '1.0'
    Id = '3f98354a-18b4-52d2-b1de-102df99241d5'
    Identity = @{
        PackageName = 'Fortinet-VPN-Profile'
        ScriptName = 'Detect-Fortinet-VPN-Profile'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Will detect if VPN profile is present.'
        Authors = @('Simon Skotheimsvik', 'Simon')
        Source = 'Fortinet-VPN-Profile/detection_FortinetVPNProfile-Detect.ps1'
        Counterpart = 'Fortinet-VPN-Profile/Remediate-Fortinet-VPN-Profile.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $false
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Test-Path', 'Write-Host')
        Executables = @()
        Policies = @('HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$VPNName')
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'VpnName'
            Required = $true
            Secret = $false
            Description = 'Fortinet VPN profile name.'
        }
    )
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Registry', 'File', 'Network')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
