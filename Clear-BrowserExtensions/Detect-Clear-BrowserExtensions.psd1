@{
    SchemaVersion = '1.0'
    Id = '649abb84-f9e3-5250-a70b-00da8dda1493'
    Identity = @{
        PackageName = 'Clear-BrowserExtensions'
        ScriptName = 'Detect-Clear-BrowserExtensions'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects unapproved browser extensions in Chrome and Edge.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Clear-BrowserExtensions/detection_detect-browserextensions.ps1'
        Counterpart = 'Clear-BrowserExtensions/Remediate-Clear-BrowserExtensions.ps1'
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
            'Get-ChildItem'
            'Join-Path'
            'Test-Path'
            'Where-Object'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'ApprovedExtensions'
            Required = $true
            Secret = $false
            Description = 'Approved browser extension identifier allowlist.'
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
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
