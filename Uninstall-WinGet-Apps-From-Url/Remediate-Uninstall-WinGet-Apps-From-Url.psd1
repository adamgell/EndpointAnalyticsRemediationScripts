@{
    SchemaVersion = '1.0'
    Id = 'efeed7fb-d8d4-5c3e-9004-05f4776442b5'
    Identity = @{
        PackageName = 'Uninstall-WinGet-Apps-From-Url'
        ScriptName = 'Remediate-Uninstall-WinGet-Apps-From-Url'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Uninstalls apps from a list via winget.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Winget Management/remediation_remediate-uninstall-apps-from-url.ps1'
        Counterpart = 'Uninstall-WinGet-Apps-From-Url/Detect-Uninstall-WinGet-Apps-From-Url.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('get-content', 'Invoke-WebRequest', 'New-Item', 'remove-item', 'rename-item', 'Resolve-Path', 'select-object', 'Set-Location', 'Start-Sleep', 'Test-Path', 'write-host', 'Write-Output')
        Executables = @('.\winget.exe', 'winget.exe')
        Policies = @()
        Endpoints = @('https://github.com/andrew-s-taylor/winget/raw/main/uninstall-apps.txt')
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
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Uninstall WinGet Apps From Url operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('File', 'Process', 'Network', 'Rest', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
