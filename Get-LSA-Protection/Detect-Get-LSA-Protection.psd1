@{
    SchemaVersion = '1.0'
    Id = '965f3e17-cae7-550e-ae10-1e3dee671548'
    Identity = @{
        PackageName = 'Get-LSA-Protection'
        ScriptName = 'Detect-Get-LSA-Protection'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Get LSA Protection condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Get-LSA-Protection/detection_Detect_LSA_Protection.ps1'
        Counterpart = 'Get-LSA-Protection/Remediate-Get-LSA-Protection.ps1'
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
            'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
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
