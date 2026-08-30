@{
    SchemaVersion = '1.0'
    Id = '5baf1952-d918-59d8-974a-d8dbb17e46ae'
    Identity = @{
        PackageName = 'Remove-Teams-Chat'
        ScriptName = 'Remediate-Remove-Teams-Chat'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Removes Teams Chat (fully).'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Remove Teams Chat/remediation_remediate-teams-chat.ps1'
        Counterpart = 'Remove-Teams-Chat/Detect-Remove-Teams-Chat.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
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
            'Get-AppxPackage'
            'Get-AppxProvisionedPackage'
            'Get-FileHash'
            'Invoke-WebRequest'
            'New-Item'
            'Remove-AppxPackage'
            'Remove-AppxProvisionedPackage'
            'Remove-Item'
            'Set-ItemProperty'
            'Test-Path'
            'Where-Object'
            'write-host'
        )
        Executables = @(
            'SetACL.exe'
        )
        Policies = @(
            'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications'
            'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat'
        )
        Endpoints = @(
            'https://github.com/andrew-s-taylor/public/raw/main/De-Bloat/SetACL.exe'
        )
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Remove Teams Chat operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @(
            'Appx'
            'Registry'
            'Rest'
            'File'
            'Native'
            'Destructive'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
