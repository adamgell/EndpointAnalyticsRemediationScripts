@{
    SchemaVersion = '1.0'
    Id = 'ca5dcccb-3602-5e0b-9bab-8c516ef79875'
    Identity = @{
        PackageName = 'Fix-SearchIndex'
        ScriptName = 'Remediate-Fix-SearchIndex'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Rebuilds the Windows Search index.'
        Authors = @('Jannik Reinhard')
        Source = 'Fix-SearchIndex/remediation_fix-searchindex.ps1'
        Counterpart = 'Fix-SearchIndex/Detect-Fix-SearchIndex.ps1'
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
        Cmdlets = @('New-ItemProperty', 'Out-Null', 'Remove-Item', 'Start-Service', 'Start-Sleep', 'Stop-Service', 'Test-Path', 'Write-Error', 'Write-Output')
        Executables = @()
        Policies = @('HKLM:\SOFTWARE\Microsoft\Windows Search')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Fix SearchIndex operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('Registry', 'Service', 'File', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
