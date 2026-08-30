@{
    SchemaVersion = '1.0'
    Id = 'aded9a61-0872-54b9-a68b-069676de321d'
    Identity = @{
        PackageName = 'Fortinet-VPN-Profile'
        ScriptName = 'Remediate-Fortinet-VPN-Profile'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Will create a VPN profile.'
        Authors = @('Simon Skotheimsvik', 'Simon')
        Source = 'Fortinet-VPN-Profile/remediation_FortinetVPNProfile-Remediation.ps1'
        Counterpart = 'Fortinet-VPN-Profile/Detect-Fortinet-VPN-Profile.ps1'
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
        Cmdlets = @('New-Item', 'New-ItemProperty', 'Test-Path')
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
        @{
            Name = 'Server'
            Required = $true
            Secret = $false
            Description = 'Fortinet VPN server and port.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Fortinet VPN Profile state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
