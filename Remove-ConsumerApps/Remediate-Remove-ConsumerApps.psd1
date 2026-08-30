@{
    SchemaVersion = '1.0'
    Id = '3b1da11d-396a-5d82-8cbd-9d9fb4cfa933'
    Identity = @{
        PackageName = 'Remove-ConsumerApps'
        ScriptName = 'Remediate-Remove-ConsumerApps'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Remove ConsumerApps condition.'
        Authors = @(
            'Marius Wyss'
        )
        Source = 'Remove-ConsumerApps/remediation_Remove-ConsumerAppsRemediation.ps1'
        Counterpart = 'Remove-ConsumerApps/Detect-Remove-ConsumerApps.ps1'
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
            'Get-AppxPackage'
            'Out-Null'
            'Remove-AppxPackage'
            'Remove-AppxProvisionedPackage'
            'Where-Object'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'ConsumerApps'
            Required = $false
            Secret = $false
            Description = 'Map of removable consumer Appx package names and display names.'
        }
    )
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Remove ConsumerApps operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Appx'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
