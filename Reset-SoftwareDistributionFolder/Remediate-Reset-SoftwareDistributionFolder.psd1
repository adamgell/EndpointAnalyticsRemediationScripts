@{
    SchemaVersion = '1.0'
    Id = 'bb30e16e-c883-55bb-996e-0ff448bd7ba5'
    Identity = @{
        PackageName = 'Reset-SoftwareDistributionFolder'
        ScriptName = 'Remediate-Reset-SoftwareDistributionFolder'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Script to reset the SoftwareDistribution folder by stopping Windows Updates services, renaming the folder to SoftwareDistribution.old and starting the services again.'
        Authors = @('Jose Schenardie')
        Source = 'Reset-SoftwareDistributionFolder/remediation_Remediate-Reset-SoftwareDistributionFolder.ps1'
        Counterpart = 'Reset-SoftwareDistributionFolder/Detect-Reset-SoftwareDistributionFolder.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-Service', 'Rename-Item', 'Start-Service', 'Stop-Service')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Reset SoftwareDistributionFolder operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('Service', 'File', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
