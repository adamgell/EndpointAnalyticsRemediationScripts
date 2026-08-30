@{
    SchemaVersion = '1.0'
    Id = 'c33ed7d7-f359-5864-afe3-fa6b310ad22c'
    Identity = @{
        PackageName = 'Remove-ReinstallMSI'
        ScriptName = 'Detect-Remove-ReinstallMSI'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if a specified MSI application is installed and checks its version.'
        Authors = @('Jannik Reinhard')
        Source = 'Remove-ReinstallMSI/detection_Remove-ReinstallMSIDetection.ps1'
        Counterpart = 'Remove-ReinstallMSI/Remediate-Remove-ReinstallMSI.ps1'
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
        Cmdlets = @('Get-ItemProperty', 'Select-Object', 'Where-Object', 'Write-Output')
        Executables = @()
        Policies = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'AppName'
            Required = $true
            Secret = $false
            Description = 'MSI application display-name pattern.'
        }
        @{
            Name = 'DesiredVersion'
            Required = $false
            Secret = $false
            Description = 'Optional desired MSI application version.'
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
        Categories = @('Registry')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
