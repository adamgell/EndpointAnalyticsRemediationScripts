@{
    SchemaVersion = '1.0'
    Id = '22c36157-3f1c-5f22-a281-4c0245dcc631'
    Identity = @{
        PackageName = 'Fix-WMI-Repository'
        ScriptName = 'Remediate-Fix-WMI-Repository'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Repairs the WMI repository if corrupted.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Fix-WMI-Repository/remediation_fix-wmirepository.ps1'
        Counterpart = 'Fix-WMI-Repository/Detect-Fix-WMI-Repository.ps1'
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
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'winmgmt'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Critical'
        Destructive = $true
        UserImpact = 'The Fix WMI Repository operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Process'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
