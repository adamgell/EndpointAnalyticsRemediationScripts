@{
    SchemaVersion = '1.0'
    Id = '5760c474-9c37-569f-9438-ccdb543cd476'
    Identity = @{
        PackageName = 'Uninstall-DellSupportAssist'
        ScriptName = 'Detect-Uninstall-DellSupportAssist'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects DellSupportAssist installation.'
        Authors = @(
            'Jasper van der Straten'
        )
        Source = 'Uninstall-DellSupportAssist/detection_Detect_DellSupportassist.ps1'
        Counterpart = 'Uninstall-DellSupportAssist/Remediate-Uninstall-DellSupportAssist.ps1'
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
            'Select-Object'
            'Where-Object'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
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
