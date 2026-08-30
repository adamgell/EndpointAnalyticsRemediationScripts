@{
    SchemaVersion = '1.0'
    Id = '4de27233-ac10-5b8d-bb92-24b4334474e3'
    Identity = @{
        PackageName = 'Copy-FilesToBlobStorage'
        ScriptName = 'Remediate-Copy-FilesToBlobStorage'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Uploads specified files to Azure Blob Storage using a SAS token.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Copy-FilesToBlobStorage/remediation_Copy-FilesToBlobStorageRemediation.ps1'
        Counterpart = 'Copy-FilesToBlobStorage/Detect-Copy-FilesToBlobStorage.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-ChildItem'
            'Get-Date'
            'Get-Item'
            'Invoke-RestMethod'
            'New-Item'
            'Out-Null'
            'Select-Object'
            'Set-Content'
            'Test-Path'
            'Where-Object'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @()
        Endpoints = @(
            'https://$StorageAccountName.blob.core.windows.net/$ContainerName'
        )
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
        @{
            Name = 'StorageAccountName'
            Required = $true
            Secret = $false
            Description = 'Azure Storage account name.'
        }
        @{
            Name = 'ContainerName'
            Required = $true
            Secret = $false
            Description = 'Azure Blob container name.'
        }
        @{
            Name = 'SasToken'
            Required = $true
            Secret = $true
            Description = 'Azure Blob shared-access signature token.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Copy FilesToBlobStorage state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
    }
    Test = @{
        Categories = @(
            'File'
            'Network'
            'Rest'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
