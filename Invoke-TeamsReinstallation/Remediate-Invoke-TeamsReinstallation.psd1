@{
    SchemaVersion = '1.0'
    Id = 'e41bad12-bb75-5684-9176-0a7f8458345b'
    Identity = @{
        PackageName = 'Invoke-TeamsReinstallation'
        ScriptName = 'Remediate-Invoke-TeamsReinstallation'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Invoke TeamsReinstallation condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Invoke-TeamsReinstallation/remediation_Invoke-TeamsReinstallationRemedaiton.ps1'
        Counterpart = 'Invoke-TeamsReinstallation/Detect-Invoke-TeamsReinstallation.ps1'
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
        Cmdlets = @('Get-WmiObject', 'new-object', 'Start-Process', 'Where-Object')
        Executables = @('msiexec.exe')
        Policies = @()
        Endpoints = @('https://aka.ms/teams64bitmsi', 'System.Net.WebClient')
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The script changes the Invoke TeamsReinstallation state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Network', 'Process', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
