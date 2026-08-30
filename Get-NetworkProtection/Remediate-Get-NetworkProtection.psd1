@{
    SchemaVersion = '1.0'
    Id = '012589f6-c1ae-5925-bf95-25eb45d34e7b'
    Identity = @{
        PackageName = 'Get-NetworkProtection'
        ScriptName = 'Remediate-Get-NetworkProtection'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Get NetworkProtection condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Get-NetworkProtection/remediation_Remediate_NetworkProtection.ps1'
        Counterpart = 'Get-NetworkProtection/Detect-Get-NetworkProtection.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Set-MpPreference', 'Write-Output')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Get NetworkProtection state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
