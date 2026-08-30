@{
    SchemaVersion = '1.0'
    Id = 'a8c73a12-5453-52c9-a573-f781b36baa01'
    Identity = @{
        PackageName = 'Reset-StartMenu'
        ScriptName = 'Remediate-Reset-StartMenu'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Resets the Start Menu layout and database.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Reset-StartMenu/remediation_reset-startmenu.ps1'
        Counterpart = 'Reset-StartMenu/Detect-Reset-StartMenu.ps1'
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
            'Add-AppxPackage'
            'ForEach-Object'
            'Get-AppxPackage'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $true
        UserImpact = 'The Reset StartMenu operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Appx'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
