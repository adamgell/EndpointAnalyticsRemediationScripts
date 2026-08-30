@{
    SchemaVersion = '1.0'
    Id = 'abeb0ed3-7816-5641-989c-77af0395c48a'
    Identity = @{
        PackageName = 'Update-ChocolateyApps'
        ScriptName = 'Remediate-Update-ChocolateyApps'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Update ChocolateyApps condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Update-ChocolateyApps/remediation_remediation-choco-upgrade.ps1'
        Counterpart = 'Update-ChocolateyApps/Detect-Update-ChocolateyApps.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Select-Object', 'Where-Object', 'Write-Error', 'Write-Output')
        Executables = @('choco.exe')
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'UpgradeExcludes'
            Required = $false
            Secret = $false
            Description = 'Chocolatey package identifiers excluded from upgrades.'
        }
        @{
            Name = 'MaxPackagesPerRun'
            Required = $false
            Secret = $false
            Description = 'Maximum Chocolatey packages upgraded per remediation run.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Update ChocolateyApps state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Process')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
