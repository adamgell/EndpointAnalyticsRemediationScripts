@{
    SchemaVersion = '1.0'
    Id = '5f3cabcf-ac24-5582-bc71-56511da4c947'
    Identity = @{
        PackageName = 'Fix-OfficeActivation'
        ScriptName = 'Detect-Fix-OfficeActivation'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Microsoft Office is properly activated.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Fix-OfficeActivation/detection_detect-officeactivation.ps1'
        Counterpart = 'Fix-OfficeActivation/Remediate-Fix-OfficeActivation.ps1'
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
            'Test-Path'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @(
            'cscript'
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
            'File'
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
