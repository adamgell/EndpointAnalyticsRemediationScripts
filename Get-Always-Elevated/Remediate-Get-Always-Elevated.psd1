@{
    SchemaVersion = '1.0'
    Id = '40b5433e-e100-5b70-81a2-4186de399b2a'
    Identity = @{
        PackageName = 'Get-Always-Elevated'
        ScriptName = 'Remediate-Get-Always-Elevated'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Get Always Elevated condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Get-Always_Elevated/remediation_Remediate_Always_Elevated.ps1'
        Counterpart = 'Get-Always-Elevated/Detect-Get-Always-Elevated.ps1'
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
        Cmdlets = @('New-Item', 'New-ItemProperty')
        Executables = @()
        Policies = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\', 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Get Always Elevated state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
