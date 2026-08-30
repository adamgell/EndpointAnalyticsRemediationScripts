@{
    SchemaVersion = '1.0'
    Id = '138c4f34-2953-5ecd-be1b-8fc465db5731'
    Identity = @{
        PackageName = 'Enforce-DOH'
        ScriptName = 'Remediate-Enforce-DOH'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Enables DNS over HTTPS (DoH) system-wide.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Enforce-DOH/remediation_enforce-doh.ps1'
        Counterpart = 'Enforce-DOH/Detect-Enforce-DOH.ps1'
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
        Reboot = 'Possible'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'New-Item'
            'New-ItemProperty'
            'Out-Null'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Enforce DOH state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
            'Network'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
