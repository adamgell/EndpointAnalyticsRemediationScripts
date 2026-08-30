@{
    SchemaVersion = '1.0'
    Id = 'de6ac4a6-3554-5da3-a7be-73491972b832'
    Identity = @{
        PackageName = 'Enable-DotNet-35'
        ScriptName = 'Remediate-Enable-DotNet-35'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Installs .NET 3.5.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard', 'Nico')
        Source = 'Enable-DotNet-35/remediation_RemediateDotNet35.ps1'
        Counterpart = 'Enable-DotNet-35/Detect-Enable-DotNet-35.ps1'
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
        Cmdlets = @('Enable-WindowsOptionalFeature', 'Write-host', 'Write-Output')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Enable DotNet 35 state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
