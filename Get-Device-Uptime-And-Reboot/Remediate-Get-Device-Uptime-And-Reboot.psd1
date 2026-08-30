@{
    SchemaVersion = '1.0'
    Id = 'ebee1177-bff2-5a6d-bb52-e0f2611f7434'
    Identity = @{
        PackageName = 'Get-Device-Uptime-And-Reboot'
        ScriptName = 'Remediate-Get-Device-Uptime-And-Reboot'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Reports device uptime and prompts the user to restart after seven days.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Get-DeviceUptime_and_Reboot/remediation_Remediate_DeviceUptime7.ps1'
        Counterpart = 'Get-Device-Uptime-And-Reboot/Detect-Get-Device-Uptime-And-Reboot.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
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
            'get-computerinfo'
            'Get-ItemProperty'
            'Invoke-WebRequest'
            'New-Item'
            'New-ItemProperty'
            'New-Object'
            'Select-Object'
            'Test-Path'
            'Write-Output'
        )
        Executables = @(
            'powershell.exe'
        )
        Policies = @(
            'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'
        )
        Endpoints = @(
            'https://raw.githubusercontent.com/insignit/endpointmanagerbranding/master/insignit_512.jpg'
            'https://raw.githubusercontent.com/insignit/endpointmanagerbranding/master/InsignIT_hero.png'
        )
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact =
        'The script changes the Get Device Uptime And Reboot state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Network'
            'Registry'
            'Ui'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
