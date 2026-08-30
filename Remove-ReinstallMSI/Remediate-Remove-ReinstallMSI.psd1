@{
    SchemaVersion = '1.0'
    Id = '2bd24222-4886-5e07-b6ba-621da104d2d2'
    Identity = @{
        PackageName = 'Remove-ReinstallMSI'
        ScriptName = 'Remediate-Remove-ReinstallMSI'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Removes and optionally reinstalls a specified MSI application.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Remove-ReinstallMSI/remediation_Remove-ReinstallMSIRemediation.ps1'
        Counterpart = 'Remove-ReinstallMSI/Detect-Remove-ReinstallMSI.ps1'
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
            'Get-ItemProperty'
            'Start-Process'
            'Test-Path'
            'Where-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'msiexec.exe'
            'cmd.exe'
        )
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        )
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
            Name = 'ReinstallMSIPath'
            Required = $false
            Secret = $false
            Description = 'Optional MSI package path used for reinstallation.'
        }
        @{
            Name = 'ReinstallArgs'
            Required = $false
            Secret = $false
            Description = 'MSI reinstallation command-line arguments.'
        }
    )
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Remove ReinstallMSI operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
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
