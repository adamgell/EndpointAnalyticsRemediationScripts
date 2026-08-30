@{
    SchemaVersion = '1.0'
    Id = 'd866a062-963d-59c8-9ea6-0f4b8daa045a'
    Identity = @{
        PackageName = 'Clear-TempFiles-Advanced'
        ScriptName = 'Detect-Clear-TempFiles-Advanced'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if temporary files exceed 2GB in total.'
        Authors = @('Jannik Reinhard')
        Source = 'Clear-TempFiles-Advanced/detection_detect-tempfiles.ps1'
        Counterpart = 'Clear-TempFiles-Advanced/Remediate-Clear-TempFiles-Advanced.ps1'
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
        Cmdlets = @('Get-ChildItem', 'Measure-Object', 'Test-Path', 'Write-Output', 'Write-Warning')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'MaxSizeMB'
            Required = $false
            Secret = $false
            Description = 'Maximum acceptable temporary-file size in megabytes.'
        }
    )
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
