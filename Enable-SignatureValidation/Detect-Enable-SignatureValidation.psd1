@{
    SchemaVersion = '1.0'
    Id = '3325824d-c321-512e-8e5d-b58827ea21c8'
    Identity = @{
        PackageName = 'Enable-SignatureValidation'
        ScriptName = 'Detect-Enable-SignatureValidation'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Written to resolve this https://msrc.microsoft.com/update-guide/vulnerability/CVE-2013-3900.'
        Authors = @(
            'Tom Coleman'
        )
        Source = 'Enable-SignatureValidation/detection_Detect_Signature_Validation.ps1'
        Counterpart = 'Enable-SignatureValidation/Remediate-Enable-SignatureValidation.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Test-Path'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Cryptography\Wintrust\Config'
            'Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config'
        )
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
        Categories = @(
            'Registry'
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
