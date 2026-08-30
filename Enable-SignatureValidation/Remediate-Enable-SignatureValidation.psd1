@{
    SchemaVersion = '1.0'
    Id = '162fe7c5-6e81-5abe-bce7-201f4257f151'
    Identity = @{
        PackageName = 'Enable-SignatureValidation'
        ScriptName = 'Remediate-Enable-SignatureValidation'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Written to resolve this https://msrc.microsoft.com/update-guide/vulnerability/CVE-2013-3900.'
        Authors = @(
            'Tom Coleman'
        )
        Source = 'Enable-SignatureValidation/remediation_Remediate_Signature_Validation.ps1'
        Counterpart = 'Enable-SignatureValidation/Detect-Enable-SignatureValidation.ps1'
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
        Reboot = 'Required'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'New-Item'
            'new-itemproperty'
            'Out-null'
            'Test-Path'
        )
        Executables = @(
            'shutdown.exe'
        )
        Policies = @(
            'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Cryptography\Wintrust\Config'
            'Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Enable SignatureValidation state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
