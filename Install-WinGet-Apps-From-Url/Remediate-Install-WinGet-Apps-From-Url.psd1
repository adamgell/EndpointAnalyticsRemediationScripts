@{
    SchemaVersion = '1.0'
    Id = 'e57fe66b-4385-5784-bf15-9d567cfb6fb7'
    Identity = @{
        PackageName = 'Install-WinGet-Apps-From-Url'
        ScriptName = 'Remediate-Install-WinGet-Apps-From-Url'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Installs apps from a URL via winget.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Winget Management/remediation_remediate-install-apps-from-url.ps1'
        Counterpart = 'Install-WinGet-Apps-From-Url/Detect-Install-WinGet-Apps-From-Url.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'get-content'
            'Invoke-WebRequest'
            'New-Item'
            'remove-item'
            'rename-item'
            'Resolve-Path'
            'select-object'
            'Set-Location'
            'Start-Sleep'
            'Test-Path'
            'write-host'
            'Write-Output'
        )
        Executables = @(
            '.\winget.exe'
            'winget.exe'
        )
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
        Level = 'High'
        Destructive = $false
        UserImpact =
        'The script changes the Install WinGet Apps From Url state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Network'
            'File'
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
