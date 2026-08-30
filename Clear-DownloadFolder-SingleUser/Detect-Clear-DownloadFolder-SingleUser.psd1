@{
    SchemaVersion = '1.0'
    Id = '4309b21f-5972-515f-9217-345437bccdb1'
    Identity = @{
        PackageName = 'Clear-DownloadFolder-SingleUser'
        ScriptName = 'Detect-Clear-DownloadFolder-SingleUser'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Checks if there is anything in the download folder.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Clear-DownloadFolder-SingleUser/detection_Clear-DownloadFolderDetection.ps1'
        Counterpart = 'Clear-DownloadFolder-SingleUser/Remediate-Clear-DownloadFolder-SingleUser.ps1'
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
            'Get-ChildItem'
            'write-host'
        )
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
        Categories = @(
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
