@{
    SchemaVersion = '1.0'
    Id = '705e70f7-bce0-5227-8ebd-c7e071c9c7c5'
    Identity = @{
        PackageName = 'Get-OfficeTelemetry'
        ScriptName = 'Detect-Get-OfficeTelemetry'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Disable O365 from sharing telemetry.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Get-OfficeTelemetry/detection_Detect_Office_Telemetry.ps1'
        Counterpart = 'Get-OfficeTelemetry/Remediate-Get-OfficeTelemetry.ps1'
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
        Cmdlets = @('Get-ItemProperty', 'Select-Object', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @('HKCU:\Software\Policies\Microsoft\office\common\clienttelemetry')
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
        Categories = @('Registry')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
