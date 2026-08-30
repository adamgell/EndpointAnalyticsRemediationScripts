@{
    SchemaVersion = '1.0'
    Id = '0f9dcfb5-7c95-5843-afcb-1739901e217d'
    Identity = @{
        PackageName = 'Profile-Backup'
        ScriptName = 'Detect-Profile-Backup'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if backup has been run in the last hour.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Profile-Backup/detection_detect-backup.ps1'
        Counterpart = 'Profile-Backup/Remediate-Profile-Backup.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-Content', 'Get-Date', 'write-host')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads the local backup timestamp marker; detection does not transfer profile data.'
    }
    Test = @{
        Categories = @('File', 'Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
