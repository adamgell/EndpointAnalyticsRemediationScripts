@{
    SchemaVersion = '1.0'
    Id = '6d7be66b-9d38-5f85-9c3d-5bc34e99b1e5'
    Identity = @{
        PackageName = 'Optimize-StartupPrograms'
        ScriptName = 'Detect-Optimize-StartupPrograms'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects excessive startup programs (more than 10 enabled entries).'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Optimize-StartupPrograms/detection_detect-startupprograms.ps1'
        Counterpart = 'Optimize-StartupPrograms/Remediate-Optimize-StartupPrograms.ps1'
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
            'Test-Path'
            'Where-Object'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
        )
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'MaxStartupItems'
            Required = $false
            Secret = $false
            Description = 'Maximum accepted enabled startup-entry count.'
        }
    )
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
