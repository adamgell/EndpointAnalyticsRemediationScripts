@{
    SchemaVersion = '1.0'
    Id = 'd7c8d40f-4643-5aec-ac6e-d25542df604c'
    Identity = @{
        PackageName = 'Uninstall-UserChrome'
        ScriptName = 'Remediate-Uninstall-UserChrome'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Uninstalls if app exists, only checks/uninstalls per-user Chrome in HKCU.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Adam Gell'
        )
        Source = 'Uninstall-UserChrome/remediation_remediate.ps1'
        Counterpart = 'Uninstall-UserChrome/Detect-Uninstall-UserChrome.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
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
            'Get-ChildItem'
            'Get-ItemProperty'
            'Select-Object'
            'start-process'
            'write-host'
        )
        Executables = @(
            'cmd.exe'
            'msiexec.exe'
        )
        Policies = @(
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Uninstall UserChrome operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
            'Process'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
