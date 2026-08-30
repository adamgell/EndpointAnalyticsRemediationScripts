@{
    SchemaVersion = '1.0'
    Id = 'e2e35eab-c110-55ee-b036-f33b0eb5043e'
    Identity = @{
        PackageName = 'Autologon'
        ScriptName = 'Detect-Autologon'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Windows Autologon is configured.'
        Authors = @('Jannik Reinhard')
        Source = 'Detect-Autologon/detection_Detect-AutologonDetection.ps1'
        Counterpart = 'Autologon/Remediate-Autologon.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ItemProperty', 'Write-Error', 'Write-Output')
        Executables = @()
        Policies = @('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
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
