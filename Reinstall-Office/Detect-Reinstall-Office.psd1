@{
    SchemaVersion = '1.0'
    Id = 'c6c6d293-b272-50cd-a78f-7b1fb72e46ab'
    Identity = @{
        PackageName = 'Reinstall-Office'
        ScriptName = 'Detect-Reinstall-Office'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Microsoft 365 Apps (Office) installation is broken or missing.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reinstall-Office/detection_Reinstall-OfficeDetection.ps1'
        Counterpart = 'Reinstall-Office/Remediate-Reinstall-Office.ps1'
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
            'Get-ItemProperty'
            'Join-Path'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'EXCEL.EXE'
            'OUTLOOK.EXE'
            'POWERPNT.EXE'
            'WINWORD.EXE'
        )
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'
        )
        Endpoints = @()
    }
    Configuration = @()
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
            'Process'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
