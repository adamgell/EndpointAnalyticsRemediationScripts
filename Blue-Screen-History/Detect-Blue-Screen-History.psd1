@{
    SchemaVersion = '1.0'
    Id = 'dd539f58-512b-5260-a488-ede8f4d01175'
    Identity = @{
        PackageName = 'Blue-Screen-History'
        ScriptName = 'Detect-Blue-Screen-History'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects BSOD occurrences in the last 30 days.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Detect-BlueScreenHistory/detection_detect-bluescreenhistory.ps1'
        Counterpart = 'Blue-Screen-History/Remediate-Blue-Screen-History.ps1'
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
            'Get-Date'
            'Get-WinEvent'
            'Measure-Object'
            'Where-Object'
            'Write-Output'
            'Write-Warning'
        )
        Executables = @()
        Policies = @(
            'Microsoft-Windows-WER-SystemErrorReporting'
        )
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'DaysBack'
            Required = $false
            Secret = $false
            Description = 'Number of prior days to inspect for blue-screen evidence.'
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
