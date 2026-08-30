@{
    SchemaVersion = '1.0'
    Id = '4ac1db40-7750-5442-a266-5b8c5a4f0501'
    Identity = @{
        PackageName = 'Get-TimeZone-W-Europe'
        ScriptName = 'Remediate-Get-TimeZone-W-Europe'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Get TimeZone W Europe condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Get-TimeZone_W_Europe/remediation_Remediate_TimeZone_W_Europe.ps1'
        Counterpart = 'Get-TimeZone-W-Europe/Detect-Get-TimeZone-W-Europe.ps1'
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
            'Get-ItemProperty'
            'Select-Object'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'The script changes the Get TimeZone W Europe state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Registry'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
