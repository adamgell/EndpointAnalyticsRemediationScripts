@{
    SchemaVersion = '1.0'
    Id = '7cf70fd3-b47f-59ba-bd6b-6fbd4b9319a2'
    Identity = @{
        PackageName = 'Get-CleanUpDisk'
        ScriptName = 'Remediate-Get-CleanUpDisk'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Get CleanUpDisk condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Get-CleanUpDisk/remediation_Get-CleanUpDiskRemedaiton.ps1'
        Counterpart = 'Get-CleanUpDisk/Detect-Get-CleanUpDisk.ps1'
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
            'New-ItemProperty'
            'Out-Null'
            'Start-Process'
        )
        Executables = @(
            'CleanMgr.exe'
        )
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$keyName'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Get CleanUpDisk operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Registry'
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
