@{
    SchemaVersion = '1.0'
    Id = '27addb02-71ca-5c86-8103-46b5c747c424'
    Identity = @{
        PackageName = 'Remove-SavedWifiProfiles'
        ScriptName = 'Detect-Remove-SavedWifiProfiles'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects saved WiFi profiles that use insecure authentication (Open/WEP).'
        Authors = @('Jannik Reinhard')
        Source = 'Remove-SavedWifiProfiles/detection_detect-savedwifiprofiles.ps1'
        Counterpart = 'Remove-SavedWifiProfiles/Remediate-Remove-SavedWifiProfiles.ps1'
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
        Cmdlets = @('ForEach-Object', 'Select-Object', 'Select-String', 'Write-Output', 'Write-Warning')
        Executables = @('netsh.exe')
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
        Categories = @('Native', 'Network')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
