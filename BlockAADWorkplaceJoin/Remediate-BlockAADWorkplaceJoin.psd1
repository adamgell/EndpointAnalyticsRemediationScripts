@{
    SchemaVersion = '1.0'
    Id = 'e5e003d0-4427-52ae-82cd-da9835d5ae2d'
    Identity = @{
        PackageName = 'BlockAADWorkplaceJoin'
        ScriptName = 'Remediate-BlockAADWorkplaceJoin'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the BlockAADWorkplaceJoin condition.'
        Authors = @('EndpointAnalyticsRemediationScripts contributors')
        Source = 'BlockAADWorkplaceJoin/remediation_Remediation-BlockAADWorkplaceJoin.ps1'
        Counterpart = 'BlockAADWorkplaceJoin/Detect-BlockAADWorkplaceJoin.ps1'
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
        Cmdlets = @('New-Item', 'New-ItemProperty', 'Out-Null', 'Test-Path')
        Executables = @()
        Policies = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the BlockAADWorkplaceJoin state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Registry', 'File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
