@{
    SchemaVersion = '1.0'
    Id = '790d6914-f42e-52fc-a9ab-a02c325f4bdd'
    Identity = @{
        PackageName = 'Clear-TempFiles-Advanced'
        ScriptName = 'Remediate-Clear-TempFiles-Advanced'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Clears temporary files, logs, crash dumps, thumbnails and prefetch.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Clear-TempFiles-Advanced/remediation_clear-tempfiles.ps1'
        Counterpart = 'Clear-TempFiles-Advanced/Detect-Clear-TempFiles-Advanced.ps1'
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
            'Join-Path'
            'Remove-Item'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Clear TempFiles Advanced operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'File'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
