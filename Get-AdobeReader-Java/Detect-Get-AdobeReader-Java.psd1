@{
    SchemaVersion = '1.0'
    Id = '361e344c-2a91-5292-af0e-0c8999803b0f'
    Identity = @{
        PackageName = 'Get-AdobeReader-Java'
        ScriptName = 'Detect-Get-AdobeReader-Java'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Get AdobeReader Java condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Get-AdobeReader-Java/detection_Detect_AdobeReader_Java.ps1'
        Counterpart = 'Get-AdobeReader-Java/Remediate-Get-AdobeReader-Java.ps1'
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
        Policies = @('HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown')
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
