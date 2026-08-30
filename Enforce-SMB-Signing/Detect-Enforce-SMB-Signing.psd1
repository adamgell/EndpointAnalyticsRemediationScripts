@{
    SchemaVersion = '1.0'
    Id = '4f252862-97d7-589d-b55f-45c51a878c8c'
    Identity = @{
        PackageName = 'Enforce-SMB-Signing'
        ScriptName = 'Detect-Enforce-SMB-Signing'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Background https://learn.microsoft.com/en-GB/troubleshoot/windows-server/networking/overview-server-message-block-signing.'
        Authors = @('EndpointAnalyticsRemediationScripts contributors')
        Source = 'Enforce-SMB-Signing/detection_Detect_SMBSigning.ps1'
        Counterpart = 'Enforce-SMB-Signing/Remediate-Enforce-SMB-Signing.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ItemProperty', 'Select-Object', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @('HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanManWorkstation\Parameters')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
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
