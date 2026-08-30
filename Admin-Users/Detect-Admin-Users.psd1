@{
    SchemaVersion = '1.0'
    Id = '64c2ed6f-f4ac-5bd9-b5a8-70e27bc740bd'
    Identity = @{
        PackageName = 'Admin-Users'
        ScriptName = 'Detect-Admin-Users'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects unauthorized local administrator accounts.'
        Authors = @('Jannik Reinhard')
        Source = 'Detect-AdminUsers/detection_detect-adminusers.ps1'
        Counterpart = 'Admin-Users/Remediate-Admin-Users.ps1'
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
        Cmdlets = @('ForEach-Object', 'Get-LocalGroupMember', 'Write-Output', 'Write-Warning')
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
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
