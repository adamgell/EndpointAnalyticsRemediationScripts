@{
    SchemaVersion = '1.0'
    Id = 'a9aec133-d216-5e7d-82b7-4324863d04db'
    Identity = @{
        PackageName = 'Admin-Users'
        ScriptName = 'Remediate-Admin-Users'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Removes unauthorized users from the local Administrators group.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Detect-AdminUsers/remediation_remove-adminusers.ps1'
        Counterpart = 'Admin-Users/Detect-Admin-Users.ps1'
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
            'Get-LocalGroupMember'
            'Remove-LocalGroupMember'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'AllowedAdmins'
            Required = $true
            Secret = $false
            Description = 'Local administrator account allowlist.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Admin Users state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
