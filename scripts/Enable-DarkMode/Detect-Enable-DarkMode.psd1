@{
    SchemaVersion = '1.0'
    Id = '183f7225-af1c-59a2-abb2-cae798631c9f'
    Identity = @{
        PackageName = 'Enable-DarkMode'
        ScriptName = 'Detect-Enable-DarkMode'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if system-wide dark mode is enabled.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Enable-DarkMode/detection_detect-darkmode.ps1'
        Counterpart = 'Enable-DarkMode/Remediate-Enable-DarkMode.ps1'
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
            'Get-ItemProperty'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
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
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
