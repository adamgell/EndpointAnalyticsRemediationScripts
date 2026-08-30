@{
    SchemaVersion = '1.0'
    Id = '2bcc06a8-2612-5da4-89f8-7968776fcc44'
    Identity = @{
        PackageName = 'Fix-SearchIndex'
        ScriptName = 'Detect-Fix-SearchIndex'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Windows Search indexing is working properly.'
        Authors = @('Jannik Reinhard')
        Source = 'Fix-SearchIndex/detection_detect-searchindex.ps1'
        Counterpart = 'Fix-SearchIndex/Remediate-Fix-SearchIndex.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-Item', 'Get-Service', 'Test-Path', 'Write-Output', 'Write-Warning')
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
        Categories = @('Service', 'File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
