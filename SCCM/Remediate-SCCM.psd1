@{
    SchemaVersion = '1.0'
    Id = '88d3fe55-8adb-53a1-bf89-b3b9b917890e'
    Identity = @{
        PackageName = 'SCCM'
        ScriptName = 'Remediate-SCCM'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the SCCM condition.'
        Authors = @(
            'EndpointAnalyticsRemediationScripts contributors'
        )
        Source = 'Detect-SCCM/remediation_RemoveSCCM.ps1'
        Counterpart = 'SCCM/Detect-SCCM.ps1'
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
            'Start-Process'
            'Test-Path'
            'Write-Output'
        )
        Executables = @(
            'ccmsetup.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The SCCM operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'File'
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
