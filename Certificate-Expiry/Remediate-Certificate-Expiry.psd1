@{
    SchemaVersion = '1.0'
    Id = '3d98e5fa-8958-5c1b-8351-a33a306eb35f'
    Identity = @{
        PackageName = 'Certificate-Expiry'
        ScriptName = 'Remediate-Certificate-Expiry'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Removes expired certificates from the local machine store.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Detect-CertificateExpiry/remediation_remove-expiredcertificates.ps1'
        Counterpart = 'Certificate-Expiry/Detect-Certificate-Expiry.ps1'
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
            'Get-ChildItem'
            'Get-Date'
            'Remove-Item'
            'Where-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @(
            'Cert:\LocalMachine\My'
            'Cert:\LocalMachine\My\$($Cert.Thumbprint)'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Certificate Expiry operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Registry'
            'File'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
