@{
    SchemaVersion = '1.0'
    Id = '6e012e58-e254-5fd4-9fd9-8a60149049a8'
    Identity = @{
        PackageName = 'Run-DiskDiagnostic'
        ScriptName = 'Detect-Run-DiskDiagnostic'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects disk health issues using S.M.A.R.T. data and disk status.'
        Authors = @('Jannik Reinhard')
        Source = 'Run-DiskDiagnostic/detection_Run-DiskDiagnosticDetection.ps1'
        Counterpart = 'Run-DiskDiagnostic/Remediate-Run-DiskDiagnostic.ps1'
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
        Cmdlets = @('Get-CimInstance', 'Get-PhysicalDisk', 'Write-Error', 'Write-Output')
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
        Categories = @('Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
