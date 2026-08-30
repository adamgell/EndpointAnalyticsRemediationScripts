@{
    SchemaVersion = '1.0'
    Id = '3122722c-0991-5755-a544-383aec1bdd62'
    Identity = @{
        PackageName = 'OneDrive-Folder-Always-Offline'
        ScriptName = 'Detect-OneDrive-Folder-Always-Offline'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the OneDrive Folder Always Offline condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'OneDrive Folder - Always Offline/detection_detection-ODFolderOffline.ps1'
        Counterpart = 'OneDrive-Folder-Always-Offline/Remediate-OneDrive-Folder-Always-Offline.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
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
            'Write-Error'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @(
            'attrib.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'CompanyName'
            Required = $false
            Secret = $false
            Description = 'OneDrive tenant or organization name component.'
        }
        @{
            Name = 'OneDriveFolder'
            Required = $false
            Secret = $false
            Description = 'OneDrive folder to keep available offline.'
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
        Categories = @(
            'File'
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
