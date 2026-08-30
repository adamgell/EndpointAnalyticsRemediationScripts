@{
    SchemaVersion = '1.0'
    Id = 'c60546b5-72bc-5ec7-af27-2caa7c63cabf'
    Identity = @{
        PackageName = 'Get-AdobeReader-Flash'
        ScriptName = 'Remediate-Get-AdobeReader-Flash'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Get AdobeReader Flash condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Get-AdobeReader_Flash/remediation_Remediate_AdobeReader_Flash.ps1'
        Counterpart = 'Get-AdobeReader-Flash/Detect-Get-AdobeReader-Flash.ps1'
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
        Policies = @('HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Get AdobeReader Flash state and can briefly affect users or services.'
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
