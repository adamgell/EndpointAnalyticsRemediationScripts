@{
    SchemaVersion = '1.0'
    Id = 'e5b1ae28-a01a-5dbc-bc2c-b529d399fd76'
    Identity = @{
        PackageName = 'OneDrive-Folder-Always-Offline'
        ScriptName = 'Remediate-OneDrive-Folder-Always-Offline'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the OneDrive Folder Always Offline condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'OneDrive Folder - Always Offline/remediation_remediation-ODFolderOffline.ps1'
        Counterpart = 'OneDrive-Folder-Always-Offline/Detect-OneDrive-Folder-Always-Offline.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'ForEach-Object'
            'Get-ChildItem'
            'Select-Object'
            'Write-Error'
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
        Level = 'Medium'
        Destructive = $false
        UserImpact =
        'The script changes the OneDrive Folder Always Offline state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
