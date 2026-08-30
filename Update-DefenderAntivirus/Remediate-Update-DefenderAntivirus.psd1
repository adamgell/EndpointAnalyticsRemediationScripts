@{
    SchemaVersion = '1.0'
    Id = 'f578ae0e-c883-5eb2-9ef1-5481f5e9a393'
    Identity = @{
        PackageName = 'Update-DefenderAntivirus'
        ScriptName = 'Remediate-Update-DefenderAntivirus'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Updates Windows Defender antivirus definitions.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Update-DefenderAntivirus/remediation_Update-DefenderAntivirusRemediation.ps1'
        Counterpart = 'Update-DefenderAntivirus/Detect-Update-DefenderAntivirus.ps1'
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
            'Update-MpSignature'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'The script changes the Update DefenderAntivirus state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
