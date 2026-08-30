@{
    SchemaVersion = '1.0'
    Id = 'c02df8ab-f615-57d0-b336-9ea5baa19fbb'
    Identity = @{
        PackageName = 'Make-Speedtest'
        ScriptName = 'Remediate-Make-Speedtest'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Make Speedtest condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Make-Speedtest/remediation_Run-SpeedttestRemediation.ps1'
        Counterpart = 'Make-Speedtest/Detect-Make-Speedtest.ps1'
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
        Cmdlets = @('ConvertTo-Json', 'Get-NetIPAddress', 'Invoke-WebRequest', 'Join-Path', 'Measure-Command', 'New-Object', 'Select-Object', 'Where-Object', 'Write-Host')
        Executables = @()
        Policies = @()
        Endpoints = @('.ods.opinsights.azure.com', 'https://', 'https://github.com/........', 'https://ifconfig.me/ip')
    }
    Configuration = @(
        @{
            Name = 'TestCount'
            Required = $false
            Secret = $false
            Description = 'Number of speed-test samples.'
        }
        @{
            Name = 'TestFile'
            Required = $true
            Secret = $false
            Description = 'URL of the speed-test file.'
        }
        @{
            Name = 'FileSizeMbit'
            Required = $false
            Secret = $false
            Description = 'Speed-test file size in megabits.'
        }
        @{
            Name = 'CustomerId'
            Required = $true
            Secret = $true
            Description = 'Log Analytics workspace identifier.'
        }
        @{
            Name = 'SharedKey'
            Required = $true
            Secret = $true
            Description = 'Log Analytics workspace shared key.'
        }
        @{
            Name = 'LogType'
            Required = $false
            Secret = $false
            Description = 'Log Analytics custom log type.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Make Speedtest state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
    }
    Test = @{
        Categories = @('Network', 'Rest', 'Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
