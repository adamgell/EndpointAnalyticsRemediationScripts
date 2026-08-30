@{
    SchemaVersion = '1.0'
    Id = '95f3d483-48ac-59fa-9665-64defec0395d'
    Identity = @{
        PackageName = 'Test-LAPSUser'
        ScriptName = 'Remediate-Test-LAPSUser'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Test LAPSUser condition.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
            'Sascha Stumpler'
        )
        Source = 'Test-LAPSUser/remediation_new-LAPSUser.ps1'
        Counterpart = 'Test-LAPSUser/Detect-Test-LAPSUser.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
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
            'Get-Item'
            'Get-ItemProperty'
            'New-Object'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Policies\LAPS'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Critical'
        Destructive = $true
        UserImpact = 'The Test LAPSUser operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'Native'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
