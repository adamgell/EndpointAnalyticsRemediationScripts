@{
    SchemaVersion = '1.0'
    Id = '433c1557-c869-5a1f-9721-4625700f2976'
    Identity = @{
        PackageName = 'Remove-New-Outlook'
        ScriptName = 'Detect-Remove-New-Outlook'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Script detects the new Microsoft Outlook app on Windows 11 23H2.'
        Authors = @('Jeroen Burgerhout')
        Source = '0 - Template/detection_Get-TemplateDetection.ps1'
        Counterpart = 'Remove-New-Outlook/Remediate-Remove-New-Outlook.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $false
        SignatureCheck = 'NotRequired'
        SupportedWindows = @('Windows 11 23H2')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-AppxPackage', 'write-host')
        Executables = @()
        Policies = @()
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
        Categories = @('Appx')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
