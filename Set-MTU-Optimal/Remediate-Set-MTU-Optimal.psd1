@{
    SchemaVersion = '1.0'
    Id = 'fcc37816-8111-5aac-be3e-719c0a6bfa5e'
    Identity = @{
        PackageName = 'Set-MTU-Optimal'
        ScriptName = 'Remediate-Set-MTU-Optimal'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Sets optimal MTU size on network adapters.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Set-MTU-Optimal/remediation_set-mtu.ps1'
        Counterpart = 'Set-MTU-Optimal/Detect-Set-MTU-Optimal.ps1'
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
            'Get-NetIPInterface'
            'Set-NetIPInterface'
            'Where-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $false
        UserImpact = 'The script changes the Set MTU Optimal state and can briefly affect users or services.'
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
