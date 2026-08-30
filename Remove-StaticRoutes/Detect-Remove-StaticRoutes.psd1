@{
    SchemaVersion = '1.0'
    Id = '296b956a-983b-518f-8e32-b69f4f042a38'
    Identity = @{
        PackageName = 'Remove-StaticRoutes'
        ScriptName = 'Detect-Remove-StaticRoutes'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects orphaned static routes with unreachable gateways.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Remove-StaticRoutes/detection_detect-staticroutes.ps1'
        Counterpart = 'Remove-StaticRoutes/Remediate-Remove-StaticRoutes.ps1'
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
            'Get-NetRoute'
            'Test-Connection'
            'Where-Object'
            'Write-Output'
            'Write-Warning'
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
            'Network'
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
