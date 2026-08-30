@{
    SchemaVersion = '1.0'
    Id = '9d0ac435-465c-5b89-8206-eff538375171'
    Identity = @{
        PackageName = 'Remove-ProxySettings'
        ScriptName = 'Detect-Remove-ProxySettings'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Remove ProxySettings condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Remove-ProxySettings/detection_Remove-ProxySettingsDetection.ps1'
        Counterpart = 'Remove-ProxySettings/Remediate-Remove-ProxySettings.ps1'
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
        Cmdlets = @('Get-ItemProperty', 'Write-Host')
        Executables = @('findstr.exe')
        Policies = @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings')
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
        Categories = @('Registry', 'Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
