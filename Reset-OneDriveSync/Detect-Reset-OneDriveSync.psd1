@{
    SchemaVersion = '1.0'
    Id = '01eee930-4302-5fcd-a7dd-bc23d2bb5e31'
    Identity = @{
        PackageName = 'Reset-OneDriveSync'
        ScriptName = 'Detect-Reset-OneDriveSync'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if OneDrive sync is working properly.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-OneDriveSync/detection_detect-onedrivesync.ps1'
        Counterpart = 'Reset-OneDriveSync/Remediate-Reset-OneDriveSync.ps1'
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
            'Get-Process'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @(
            'OneDrive.exe'
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
