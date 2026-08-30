@{
    SchemaVersion = '1.0'
    Id = 'aa98cf9b-0d84-5325-ad11-ffa9079656a9'
    Identity = @{
        PackageName = 'Uninstall-Visual-Cpp-2010'
        ScriptName = 'Remediate-Uninstall-Visual-Cpp-2010'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Uninstall Visual Cpp 2010 condition.'
        Authors = @('EndpointAnalyticsRemediationScripts contributors')
        Source = 'Uninstall-C++2010/remediation_Remediate_C++2010.ps1'
        Counterpart = 'Uninstall-Visual-Cpp-2010/Detect-Uninstall-Visual-Cpp-2010.ps1'
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
        Cmdlets = @('Get-AppxPackage', 'Remove-AppxPackage', 'Write-Error', 'Write-Host')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Uninstall Visual Cpp 2010 operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('Appx', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
