@{
    SchemaVersion = '1.0'
    Id = '8b522dee-e23f-5d08-a99d-03c0437440cc'
    Identity = @{
        PackageName = 'Update-MicrosoftTeams'
        ScriptName = 'Detect-Update-MicrosoftTeams'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Microsoft Teams is outdated and needs updating.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Update-MicrosoftTeams/detection_Update-MicrosoftTeamsDetection.ps1'
        Counterpart = 'Update-MicrosoftTeams/Remediate-Update-MicrosoftTeams.ps1'
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
            'Get-AppxPackage'
            'Get-ChildItem'
            'Get-ItemProperty'
            'Join-Path'
            'Select-Object'
            'Sort-Object'
            'Where-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'winget.exe'
        )
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
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
            'Appx'
            'Registry'
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
