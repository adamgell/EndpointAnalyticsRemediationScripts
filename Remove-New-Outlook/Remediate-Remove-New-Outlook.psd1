@{
    SchemaVersion = '1.0'
    Id = 'c631de60-9724-5765-b230-4277171fca7c'
    Identity = @{
        PackageName = 'Remove-New-Outlook'
        ScriptName = 'Remediate-Remove-New-Outlook'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Script removes the new Microsoft Outlook app on Windows 11 23H2.'
        Authors = @(
            'Jeroen Burgerhout'
        )
        Source = '0 - Template/remediation_Get-TemplateRemediaton.ps1'
        Counterpart = 'Remove-New-Outlook/Detect-Remove-New-Outlook.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'NotRequired'
        SupportedWindows = @(
            'Windows 11 23H2'
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
        UserImpact = 'The Remove New Outlook operation can remove data, software, accounts, or configuration.'
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
