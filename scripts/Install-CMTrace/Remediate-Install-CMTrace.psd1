@{
    SchemaVersion = '1.0'
    Id = 'd6b3d3e7-0aba-56ad-a848-72a06d3ed266'
    Identity = @{
        PackageName = 'Install-CMTrace'
        ScriptName = 'Remediate-Install-CMTrace'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Installs CMTrace to c:\windows\system32.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Install-CMTrace/remediation_install-cmtrace-remediate.ps1'
        Counterpart = 'Install-CMTrace/Detect-Install-CMTrace.ps1'
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
            'invoke-webrequest'
        )
        Executables = @(
            'cmtrace.exe'
        )
        Policies = @()
        Endpoints = @(
            'https://github.com/.......'
        )
    }
    Configuration = @(
        @{
            Name = 'OwnRepoUri'
            Required = $true
            Secret = $false
            Description = 'Repository URL that hosts the CMTrace executable.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Install CMTrace state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'File'
            'Network'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
