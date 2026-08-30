@{
    SchemaVersion = '1.0'
    Id = '2207ae58-a13a-5d9a-8b13-158a8e518286'
    Identity = @{
        PackageName = 'Remove-ProxySettings'
        ScriptName = 'Remediate-Remove-ProxySettings'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Remove ProxySettings condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Remove-ProxySettings/remediation_Remove-ProxySettingsRemedaiton.ps1'
        Counterpart = 'Remove-ProxySettings/Detect-Remove-ProxySettings.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
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
            'Set-ItemProperty'
        )
        Executables = @()
        Policies = @(
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $true
        UserImpact = 'The Remove ProxySettings operation can remove data, software, accounts, or configuration.'
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
