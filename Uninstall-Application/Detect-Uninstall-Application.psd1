@{
    SchemaVersion = '1.0'
    Id = '295d49d3-9517-57ee-a9b4-e29f87f087c1'
    Identity = @{
        PackageName = 'Uninstall-Application'
        ScriptName = 'Detect-Uninstall-Application'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if app exists.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Uninstall-Application/detection_detect.ps1'
        Counterpart = 'Uninstall-Application/Remediate-Uninstall-Application.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-ChildItem'
            'Get-ItemProperty'
            'Select-Object'
            'write-output'
        )
        Executables = @()
        Policies = @(
            'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
            'HKLM:\Software\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall'
        )
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'BlacklistApps'
            Required = $true
            Secret = $false
            Description = 'Application display names to uninstall.'
        }
    )
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
