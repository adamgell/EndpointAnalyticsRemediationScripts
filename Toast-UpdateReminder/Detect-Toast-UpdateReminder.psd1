@{
    SchemaVersion = '1.0'
    Id = '851e7ca3-1ec5-512f-b028-6ddfb06ddf08'
    Identity = @{
        PackageName = 'Toast-UpdateReminder'
        ScriptName = 'Detect-Toast-UpdateReminder'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if there are pending Windows updates or reboot required.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Toast-UpdateReminder/detection_detect-pendingupdates.ps1'
        Counterpart = 'Toast-UpdateReminder/Remediate-Toast-UpdateReminder.ps1'
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
        Reboot = 'Required'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-Date'
            'Get-HotFix'
            'Select-Object'
            'Sort-Object'
            'Test-Path'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
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
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
