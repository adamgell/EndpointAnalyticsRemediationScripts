@{
    SchemaVersion = '1.0'
    Id = 'bb82dbf9-7b2a-536f-92ce-1d337bf714c9'
    Identity = @{
        PackageName = 'Get-AdobeDC-Java'
        ScriptName = 'Detect-Get-AdobeDC-Java'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Get AdobeDC Java condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Get-AdobeDC_Java/detection_Detect_AdobeDC_Java.ps1'
        Counterpart = 'Get-AdobeDC-Java/Remediate-Get-AdobeDC-Java.ps1'
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
        Policies = @('HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown')
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
