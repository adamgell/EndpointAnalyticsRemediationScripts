@{
    SchemaVersion = '1.0'
    Id = '546cfd47-c439-5d8d-9a34-35d67ea0dc86'
    Identity = @{
        PackageName = 'Monitor-DiskSpace-Trend'
        ScriptName = 'Remediate-Monitor-DiskSpace-Trend'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Frees disk space by cleaning common locations.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Monitor-DiskSpace-Trend/remediation_free-diskspace.ps1'
        Counterpart = 'Monitor-DiskSpace-Trend/Detect-Monitor-DiskSpace-Trend.ps1'
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
            'Clear-RecycleBin'
            'ForEach-Object'
            'Get-ChildItem'
            'Join-Path'
            'New-ItemProperty'
            'Out-Null'
            'Remove-Item'
            'Start-Process'
            'Start-Service'
            'Stop-Service'
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
        UserImpact = 'The Monitor DiskSpace Trend operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'File'
            'Service'
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
