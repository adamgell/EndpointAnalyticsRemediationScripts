@{
    SchemaVersion = '1.0'
    Id = '5f2787f2-e632-55bb-97ff-721b5b06422b'
    Identity = @{
        PackageName = 'Reset-SoftwareDistributionFolder'
        ScriptName = 'Detect-Reset-SoftwareDistributionFolder'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects whether a prior SoftwareDistribution backup folder exists.'
        Authors = @(
            'Jose Schenardie'
        )
        Source = 'Reset-SoftwareDistributionFolder/detection_Detect-Reset-SoftwareDistributionFolder.ps1'
        Counterpart = 'Reset-SoftwareDistributionFolder/Remediate-Reset-SoftwareDistributionFolder.ps1'
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
        )
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
        Categories = @(
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
