@{
    SchemaVersion = '1.0'
    Id = 'f1e6f49a-4431-541f-8036-25d10ad374df'
    Identity = @{
        PackageName = 'Uninstall-PrivateTeams'
        ScriptName = 'Remediate-Uninstall-PrivateTeams'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Uninstall PrivateTeams condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Uninstall-PrivateTeams/remediation_Uninstall-PrivateTeamsRemedaiton.ps1'
        Counterpart = 'Uninstall-PrivateTeams/Detect-Uninstall-PrivateTeams.ps1'
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
            'Get-AppxPackage'
            'Remove-AppxPackage'
            'Write-Error'
            'Write-Host'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Uninstall PrivateTeams operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Appx'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
