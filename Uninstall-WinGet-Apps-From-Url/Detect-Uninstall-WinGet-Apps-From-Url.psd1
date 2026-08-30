@{
    SchemaVersion = '1.0'
    Id = 'a46dd3be-c2de-5aff-8265-d8e6c4236f1e'
    Identity = @{
        PackageName = 'Uninstall-WinGet-Apps-From-Url'
        ScriptName = 'Detect-Uninstall-WinGet-Apps-From-Url'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects changes to URL to uninstall apps via Winget.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Winget Management/detection_detect-uninstall-url-changes.ps1'
        Counterpart = 'Uninstall-WinGet-Apps-From-Url/Remediate-Uninstall-WinGet-Apps-From-Url.ps1'
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
            'get-content'
            'Invoke-WebRequest'
            'New-Item'
            'remove-item'
            'select-object'
            'Start-Sleep'
            'Test-Path'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @()
        Endpoints = @(
            'https://github.com/andrew-s-taylor/winget/raw/main/uninstall-apps.txt'
        )
    }
    Configuration = @(
        @{
            Name = 'UninstallUri'
            Required = $true
            Secret = $false
            Description = 'URL of the Winget package uninstall list.'
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
            'Network'
            'Rest'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
