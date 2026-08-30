@{
    SchemaVersion = '1.0'
    Id = '4759c1f5-cbc9-539b-9c95-9b3a5fa76dd8'
    Identity = @{
        PackageName = 'Set-Service-Generic'
        ScriptName = 'Detect-Set-Service-Generic'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if service exists and is configured as expected.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard', 'Sascha Stumpler')
        Source = 'Set-Service-Generic/detection_detect-service.ps1'
        Counterpart = 'Set-Service-Generic/Remediate-Set-Service-Generic.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-Service', 'Write-Host')
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'ServiceName'
            Required = $true
            Secret = $false
            Description = 'Windows service name.'
        }
        @{
            Name = 'ServiceOption'
            Required = $true
            Secret = $false
            Description = 'Set-Service parameter name.'
        }
        @{
            Name = 'ServiceOptionValue'
            Required = $true
            Secret = $false
            Description = 'Required Set-Service parameter value.'
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
        Categories = @('Service')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
