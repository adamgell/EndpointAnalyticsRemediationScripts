@{
    SchemaVersion = '1.0'
    Id = '727d57d5-b8fb-5b56-86a2-922209acdf7b'
    Identity = @{
        PackageName = 'Fix-FileAssociations'
        ScriptName = 'Remediate-Fix-FileAssociations'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Repairs broken file associations by resetting to Windows defaults.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Fix-FileAssociations/remediation_fix-fileassociations.ps1'
        Counterpart = 'Fix-FileAssociations/Detect-Fix-FileAssociations.ps1'
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
            'New-Item'
            'Out-Null'
            'Set-ItemProperty'
            'Test-Path'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Classes\$Ext'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Fix FileAssociations state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
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
