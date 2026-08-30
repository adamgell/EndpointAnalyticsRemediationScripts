@{
    SchemaVersion = '1.0'
    Id = '08b73020-f6ca-5aeb-ba0a-07cf5be91e31'
    Identity = @{
        PackageName = 'Enable-DotNet-35'
        ScriptName = 'Detect-Enable-DotNet-35'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if .NET 3.5 is installed.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Nico'
        )
        Source = 'Enable-DotNet-35/detection_DetectDotNet35.ps1'
        Counterpart = 'Enable-DotNet-35/Remediate-Enable-DotNet-35.ps1'
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
            'Get-WindowsOptionalFeature'
            'Join-Path'
            'Start-Transcript'
            'Write-Output'
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
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
