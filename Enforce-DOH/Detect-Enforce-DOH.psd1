@{
    SchemaVersion = '1.0'
    Id = '8b82beb0-d2e4-5523-ae2b-f507945f6ae2'
    Identity = @{
        PackageName = 'Enforce-DOH'
        ScriptName = 'Detect-Enforce-DOH'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if DNS over HTTPS (DoH) is enabled.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Enforce-DOH/detection_detect-doh.ps1'
        Counterpart = 'Enforce-DOH/Remediate-Enforce-DOH.ps1'
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
            'Get-ItemProperty'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
        )
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
            'Registry'
            'Network'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
