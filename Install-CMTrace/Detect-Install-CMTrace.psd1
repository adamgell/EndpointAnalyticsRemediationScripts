@{
    SchemaVersion = '1.0'
    Id = '65e2511c-eb34-5fb3-af19-ec66e9990bbf'
    Identity = @{
        PackageName = 'Install-CMTrace'
        ScriptName = 'Detect-Install-CMTrace'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if CMTrace is installed.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Install-CMTrace/detection_detect-cmtrace.ps1'
        Counterpart = 'Install-CMTrace/Remediate-Install-CMTrace.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
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
        Executables = @(
            'cmtrace.exe'
        )
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
