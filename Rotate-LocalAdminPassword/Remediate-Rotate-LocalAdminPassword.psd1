@{
    SchemaVersion = '1.0'
    Id = 'c2047f92-a2fd-5500-9e78-c7a2107b3bfb'
    Identity = @{
        PackageName = 'Rotate-LocalAdminPassword'
        ScriptName = 'Remediate-Rotate-LocalAdminPassword'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Rotates the local administrator password with a random secure password.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Rotate-LocalAdminPassword/remediation_rotate-localadminpassword.ps1'
        Counterpart = 'Rotate-LocalAdminPassword/Detect-Rotate-LocalAdminPassword.ps1'
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
            'ConvertTo-SecureString'
            'Get-LocalUser'
            'New-Object'
            'Set-LocalUser'
            'Where-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Critical'
        Destructive = $true
        UserImpact = 'The Rotate LocalAdminPassword operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Handles credential or token material at runtime; secret values are not stored in the manifest.'
    }
    Test = @{
        Categories = @(
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
