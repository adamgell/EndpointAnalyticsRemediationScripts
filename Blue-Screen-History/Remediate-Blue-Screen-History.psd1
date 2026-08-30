@{
    SchemaVersion = '1.0'
    Id = '0b1b3722-002f-53e3-a1f3-671be8cda464'
    Identity = @{
        PackageName = 'Blue-Screen-History'
        ScriptName = 'Remediate-Blue-Screen-History'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Analyzes BSODs and runs system file checks.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Detect-BlueScreenHistory/remediation_analyze-bluescreens.ps1'
        Counterpart = 'Blue-Screen-History/Detect-Blue-Screen-History.ps1'
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
            'ForEach-Object'
            'Get-Date'
            'Get-WinEvent'
            'Join-Path'
            'New-Item'
            'Out-File'
            'Out-Null'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'DISM'
            'sfc'
        )
        Policies = @(
            'Microsoft-Windows-WER-SystemErrorReporting'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Blue Screen History state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
