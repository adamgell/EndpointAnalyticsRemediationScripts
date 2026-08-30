@{
    SchemaVersion = '1.0'
    Id = '5b599141-7d50-5b34-8b08-ba7fb1acdc5a'
    Identity = @{
        PackageName = 'Browser-Passwords'
        ScriptName = 'Detect-Browser-Passwords'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Script detects if common Browsers have passwords stored locally.'
        Authors = @(
            'Sven Wick'
        )
        Source = 'Detect-Browser-Passwords/Detect-Browser-Passwords.ps1'
        Counterpart = ''
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'NotRequired'
        SupportedWindows = @(
            'AllSupported'
        )
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'ConvertFrom-Json'
            'Copy-Item'
            'Get-ChildItem'
            'Get-Content'
            'Get-Item'
            'Remove-Item'
            'Test-Path'
            'Where-Object'
            'Write-Output'
        )
        Executables = @(
            'sqlite3.exe'
        )
        Policies = @(
            '$env:APPDATA\Opera Software\Opera Stable\'
            '$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\'
        )
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'SqlitePath'
            Required = $true
            Secret = $false
            Description = 'Path to the sqlite3 executable used to inspect browser databases.'
        }
    )
    Risk = @{
        Level = 'Medium'
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
