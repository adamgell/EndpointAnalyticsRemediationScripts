@{
    SchemaVersion = '1.0'
    Id = '7600b47b-03f9-5e4f-9885-bc49741e956a'
    Identity = @{
        PackageName = 'Install-WinGet-Apps-From-Url'
        ScriptName = 'Detect-Install-WinGet-Apps-From-Url'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects changes to URL to trigger app install.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Winget Management/detection_detect-install-url-changes.ps1'
        Counterpart = 'Install-WinGet-Apps-From-Url/Remediate-Install-WinGet-Apps-From-Url.ps1'
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
            'https://github.com/andrew-s-taylor/winget/raw/main/install-apps.txt'
        )
    }
    Configuration = @(
        @{
            Name = 'InstallUri'
            Required = $true
            Secret = $false
            Description = 'URL of the Winget package install list.'
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
            'Network'
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
