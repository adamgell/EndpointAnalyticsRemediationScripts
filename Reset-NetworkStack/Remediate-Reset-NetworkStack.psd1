@{
    SchemaVersion = '1.0'
    Id = '34e01c5f-ed7a-5e4f-bcd1-33f17cd020f7'
    Identity = @{
        PackageName = 'Reset-NetworkStack'
        ScriptName = 'Remediate-Reset-NetworkStack'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Resets the complete network stack (Winsock, IP, DNS).'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-NetworkStack/remediation_reset-networkstack.ps1'
        Counterpart = 'Reset-NetworkStack/Detect-Reset-NetworkStack.ps1'
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
        Reboot = 'Possible'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'netsh'
            'Out-Null'
            'Write-Error'
            'Write-Output'
        )
        Executables = @(
            'netsh.exe'
            'ipconfig.exe'
        )
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Reset NetworkStack operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Native'
            'Network'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
