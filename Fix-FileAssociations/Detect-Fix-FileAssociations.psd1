@{
    SchemaVersion = '1.0'
    Id = 'b1eb6251-c2e4-5810-928f-501815ca3531'
    Identity = @{
        PackageName = 'Fix-FileAssociations'
        ScriptName = 'Detect-Fix-FileAssociations'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects broken file associations for common file types.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Fix-FileAssociations/detection_detect-fileassociations.ps1'
        Counterpart = 'Fix-FileAssociations/Remediate-Fix-FileAssociations.ps1'
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
            'Write-Output'
            'Write-Warning'
        )
        Executables = @(
            'cmd'
        )
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
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
