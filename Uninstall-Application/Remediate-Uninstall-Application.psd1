@{
    SchemaVersion = '1.0'
    Id = '44dcb17d-6a1b-5c7d-b9da-8d679df7437b'
    Identity = @{
        PackageName = 'Uninstall-Application'
        ScriptName = 'Remediate-Uninstall-Application'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Uninstalls applications whose display name matches BlacklistApps.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Uninstall-Application/remediation_remediate.ps1'
        Counterpart = 'Uninstall-Application/Detect-Uninstall-Application.ps1'
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
        Cmdlets = @('Get-ChildItem', 'Get-ItemProperty', 'Select-Object', 'start-process', 'write-host')
        Executables = @('cmd.exe', 'msiexec.exe')
        Policies = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\Software\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall')
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'BlacklistApps'
            Required = $true
            Secret = $false
            Description = 'Application display names to uninstall.'
        }
    )
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Uninstall Application operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('Registry', 'File', 'Process', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
