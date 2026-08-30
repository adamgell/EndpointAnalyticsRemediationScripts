@{
    SchemaVersion = '1.0'
    Id = 'da14670d-9c33-5807-80c3-0b51fc07e7e1'
    Identity = @{
        PackageName = 'Optimize-StartupPrograms'
        ScriptName = 'Remediate-Optimize-StartupPrograms'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Disables known unnecessary startup programs.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Optimize-StartupPrograms/remediation_optimize-startupprograms.ps1'
        Counterpart = 'Optimize-StartupPrograms/Detect-Optimize-StartupPrograms.ps1'
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
            'Get-ItemProperty'
            'Remove-ItemProperty'
            'Test-Path'
            'Write-Error'
            'Write-Output'
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
            Name = 'UnnecessaryStartup'
            Required = $false
            Secret = $false
            Description = 'Startup-entry names to disable.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $true
        UserImpact = 'The Optimize StartupPrograms operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
