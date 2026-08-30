@{
    SchemaVersion = '1.0'
    Id = '122f38d0-cafc-56e9-8ca4-7d4f1e206aaf'
    Identity = @{
        PackageName = 'Get-CloudDeliveredProtection'
        ScriptName = 'Remediate-Get-CloudDeliveredProtection'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Get CloudDeliveredProtection condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Get-CloudDeliveredProtection/remediation_Remediate_CloudDeliveredProtection.ps1'
        Counterpart = 'Get-CloudDeliveredProtection/Detect-Get-CloudDeliveredProtection.ps1'
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
        UserImpact =
        'The script changes the Get CloudDeliveredProtection state and can briefly affect users or services.'
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
