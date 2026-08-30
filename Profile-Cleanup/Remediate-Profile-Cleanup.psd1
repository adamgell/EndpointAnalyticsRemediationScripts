@{
    SchemaVersion = '1.0'
    Id = '57790020-5d57-5130-af65-ad2012719405'
    Identity = @{
        PackageName = 'Profile-Cleanup'
        ScriptName = 'Remediate-Profile-Cleanup'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Removes old user profiles over 30 days old via DelProf1 or DelProf2.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Profile-cleanup/remediation_remediate-old-profiles.ps1'
        Counterpart = 'Profile-Cleanup/Detect-Profile-Cleanup.ps1'
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
            'get-CimInstance'
            'Get-Date'
            'Get-FileHash'
            'Invoke-WebRequest'
            'Remove-Item'
            'Start-Process'
            'Where-Object'
            'write-host'
        )
        Executables = @(
            'delprof.exe'
            'delprof2.exe'
            'DelProf2.exe'
        )
        Policies = @()
        Endpoints = @(
            'https://github.com/andrew-s-taylor/public/raw/main/delprof/delprof.exe'
            'https://github.com/andrew-s-taylor/public/raw/main/delprof/DelProf2.exe'
        )
    }
    Configuration = @(
        @{
            Name = 'ProfileAgeDays'
            Required = $false
            Secret = $false
            Description = 'Minimum profile age in days for cleanup eligibility.'
        }
    )
    Risk = @{
        Level = 'Critical'
        Destructive = $true
        UserImpact = 'The Profile Cleanup operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'File'
            'Rest'
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
