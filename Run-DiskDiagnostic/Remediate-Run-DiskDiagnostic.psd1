@{
    SchemaVersion = '1.0'
    Id = 'e8b2c720-df71-5d72-b035-99d6a6662341'
    Identity = @{
        PackageName = 'Run-DiskDiagnostic'
        ScriptName = 'Remediate-Run-DiskDiagnostic'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Runs disk cleanup and optimization to remediate disk issues.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Run-DiskDiagnostic/remediation_Run-DiskDiagnosticRemediation.ps1'
        Counterpart = 'Run-DiskDiagnostic/Detect-Run-DiskDiagnostic.ps1'
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
            'Join-Path'
            'Optimize-Volume'
            'Set-ItemProperty'
            'Start-Process'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'cleanmgr.exe'
        )
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Run DiskDiagnostic operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
            'Process'
            'Native'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
