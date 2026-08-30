@{
    SchemaVersion = '1.0'
    Id = '9c54e067-6688-55c4-9cec-66951fe75419'
    Identity = @{
        PackageName = 'Reinstall-Office'
        ScriptName = 'Remediate-Reinstall-Office'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Repairs Microsoft 365 Apps (Office) installation using online repair.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reinstall-Office/remediation_Reinstall-OfficeRemediation.ps1'
        Counterpart = 'Reinstall-Office/Detect-Reinstall-Office.ps1'
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
        Reboot = 'Possible'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Join-Path'
            'Start-Process'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'OfficeC2RClient.exe'
        )
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Reinstall Office state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
