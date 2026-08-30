@{
    SchemaVersion = '1.0'
    Id = '4d8d9700-3698-5960-b18e-175562e11419'
    Identity = @{
        PackageName = 'Clear-DownloadFolder'
        ScriptName = 'Detect-Clear-DownloadFolder'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Clear DownloadFolder condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Clear-DownloadFolder/detection_Clear-DownloadFolderDetection.ps1'
        Counterpart = 'Clear-DownloadFolder/Remediate-Clear-DownloadFolder.ps1'
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
    Behavior = @{ DetectionMode = 'AlwaysRemediate' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Write-Host')
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
