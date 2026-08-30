@{
    SchemaVersion = '1.0'
    Id = '28f42122-2033-5f8c-a638-7c2b77238851'
    Identity = @{
        PackageName = 'Copy-FilesToBlobStorage'
        ScriptName = 'Detect-Copy-FilesToBlobStorage'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if specified files exist locally and need to be uploaded to Azure Blob Storage.'
        Authors = @('Jannik Reinhard')
        Source = 'Copy-FilesToBlobStorage/detection_Copy-FilesToBlobStorageDetection.ps1'
        Counterpart = 'Copy-FilesToBlobStorage/Remediate-Copy-FilesToBlobStorage.ps1'
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
        Cmdlets = @('Get-ChildItem', 'Get-Item', 'Select-Object', 'Test-Path', 'Where-Object', 'Write-Output')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'SourcePaths'
            Required = $true
            Secret = $false
            Description = 'Local directories whose files are evaluated for upload.'
        }
        @{
            Name = 'MarkerFile'
            Required = $false
            Secret = $false
            Description = 'Local marker file that tracks the last completed upload.'
        }
    )
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads local file metadata and the upload marker; detection does not transfer files.'
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
