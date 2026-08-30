@{
    SchemaVersion = '1.0'
    Id = '766b4fc9-8cd8-58b6-8cb7-5478761053c2'
    Identity = @{
        PackageName = 'Get-AdobeReader-Java'
        ScriptName = 'Remediate-Get-AdobeReader-Java'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Get AdobeReader Java condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Get-AdobeReader-Java/remediation_Remediate_AdobeReader_Java.ps1'
        Counterpart = 'Get-AdobeReader-Java/Detect-Get-AdobeReader-Java.ps1'
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
            'New-ItemProperty'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Get AdobeReader Java state and can briefly affect users or services.'
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
