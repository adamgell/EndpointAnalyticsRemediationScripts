@{
    SchemaVersion = '1.0'
    Id = 'd26b7ad1-75dd-501d-af33-6a6a765ad65c'
    Identity = @{
        PackageName = 'Get-AdobeReader-Flash'
        ScriptName = 'Detect-Get-AdobeReader-Flash'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Get AdobeReader Flash condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Get-AdobeReader_Flash/detection_Detect_AdobeReader_Flash.ps1'
        Counterpart = 'Get-AdobeReader-Flash/Remediate-Get-AdobeReader-Flash.ps1'
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
            'Get-ItemProperty'
            'Select-Object'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown'
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
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
