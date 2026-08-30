@{
    SchemaVersion = '1.0'
    Id = '19388a0d-99f1-5430-88e1-c04790c59912'
    Identity = @{
        PackageName = 'Get-RealTimeBehaviour'
        ScriptName = 'Remediate-Get-RealTimeBehaviour'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Get RealTimeBehaviour condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Get-RealTimeBehaviour/remediation_Remediate_RealTimeBehavior.ps1'
        Counterpart = 'Get-RealTimeBehaviour/Detect-Get-RealTimeBehaviour.ps1'
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
            'Get-MpComputerStatus'
            'Set-MpPreference'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Get RealTimeBehaviour state and can briefly affect users or services.'
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
