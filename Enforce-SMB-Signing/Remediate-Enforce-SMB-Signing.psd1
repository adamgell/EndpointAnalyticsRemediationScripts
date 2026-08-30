@{
    SchemaVersion = '1.0'
    Id = 'b9777b83-6f91-5998-8b3e-a12a9b95e499'
    Identity = @{
        PackageName = 'Enforce-SMB-Signing'
        ScriptName = 'Remediate-Enforce-SMB-Signing'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Background https://learn.microsoft.com/en-GB/troubleshoot/windows-server/networking/overview-server-message-block-signing.'
        Authors = @('EndpointAnalyticsRemediationScripts contributors')
        Source = 'Enforce-SMB-Signing/remediation_Remediate-SMB-Signing.ps1'
        Counterpart = 'Enforce-SMB-Signing/Detect-Enforce-SMB-Signing.ps1'
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
        Cmdlets = @('New-ItemProperty')
        Executables = @()
        Policies = @('HKLM\System\CurrentControlSet\Services\LanManWorkstation\Parameters')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Enforce SMB Signing state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Registry')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
