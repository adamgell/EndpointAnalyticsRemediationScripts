@{
    SchemaVersion = '1.0'
    Id = '6c1ee1b2-e7a4-5d82-8b0f-542eb487413b'
    Identity = @{
        PackageName = 'Get-TimeZone-W-Europe'
        ScriptName = 'Detect-Get-TimeZone-W-Europe'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Get TimeZone W Europe condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Get-TimeZone_W_Europe/detection_Get-TimeZone_W_Europe.ps1'
        Counterpart = 'Get-TimeZone-W-Europe/Remediate-Get-TimeZone-W-Europe.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ItemProperty', 'Select-Object', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @('HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation')
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
