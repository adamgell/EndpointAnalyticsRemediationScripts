@{
    SchemaVersion = '1.0'
    Id = 'd955a5cc-9f4c-5aa7-bd79-3718bd98936a'
    Identity = @{
        PackageName = 'Invoke-ClearRecycleBin'
        ScriptName = 'Detect-Invoke-ClearRecycleBin'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Invoke ClearRecycleBin condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Invoke-ClearRecycleBin/detection_Invoke-ClearRecycleBinDetection.ps1'
        Counterpart = 'Invoke-ClearRecycleBin/Remediate-Invoke-ClearRecycleBin.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
        SignatureCheck = 'Either'
        SupportedWindows = @(
            'AllSupported'
        )
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'AlwaysRemediate' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Write-Host'
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
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
