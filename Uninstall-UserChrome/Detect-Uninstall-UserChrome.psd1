@{
    SchemaVersion = '1.0'
    Id = 'e32a6b82-bf08-58ab-92bb-7aafe5739224'
    Identity = @{
        PackageName = 'Uninstall-UserChrome'
        ScriptName = 'Detect-Uninstall-UserChrome'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Uninstalls if app exists, only checks/uninstalls per-user Chrome in HKCU.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Adam Gell'
        )
        Source = 'Uninstall-UserChrome/detection_detect.ps1'
        Counterpart = 'Uninstall-UserChrome/Remediate-Uninstall-UserChrome.ps1'
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
            'Get-ItemProperty'
            'Select-Object'
            'write-output'
        )
        Executables = @()
        Policies = @(
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
        )
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
            'Registry'
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
