@{
    SchemaVersion = '1.0'
    Id = '46179c1e-fcc0-511e-8dbc-eabf3d39ea2c'
    Identity = @{
        PackageName = 'Remove-Silverlight'
        ScriptName = 'Remediate-Remove-Silverlight'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Script removes the Microsoft Silverlight.'
        Authors = @('Gerardo Hernandez')
        Source = '0 - Template/Remediate_Silverlight'
        Counterpart = 'Remove-Silverlight/Detect-Remove-Silverlight.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
        SignatureCheck = 'NotRequired'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ChildItem', 'Get-ItemProperty', 'Select-Object', 'Start-Process', 'Where-Object')
        Executables = @('msiexec.exe')
        Policies = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Remove Silverlight operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('Registry', 'File', 'Process', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
