@{
    SchemaVersion = '1.0'
    Id = '8d2596f2-f114-5dd7-a227-60e31fc5c9a2'
    Identity = @{
        PackageName = 'Fix-OfficeActivation'
        ScriptName = 'Remediate-Fix-OfficeActivation'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Repairs Office activation by clearing license cache.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Fix-OfficeActivation/remediation_fix-officeactivation.ps1'
        Counterpart = 'Fix-OfficeActivation/Detect-Fix-OfficeActivation.ps1'
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
            'Get-Process'
            'Remove-Item'
            'Start-Process'
            'Start-Sleep'
            'Stop-Process'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'OfficeC2RClient.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Fix OfficeActivation operation can remove data, software, accounts, or configuration.'
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
