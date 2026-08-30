@{
    SchemaVersion = '1.0'
    Id = 'f0d41c90-8a1b-51b4-9a89-18939cb28c97'
    Identity = @{
        PackageName = 'Uninstall-DellSupportAssist'
        ScriptName = 'Remediate-Uninstall-DellSupportAssist'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Uninstalls DellSupportAssist installation.'
        Authors = @('Jasper van der Straten')
        Source = 'Uninstall-DellSupportAssist/remediation_Remediate_DellSupportassist.ps1'
        Counterpart = 'Uninstall-DellSupportAssist/Detect-Uninstall-DellSupportAssist.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ItemProperty', 'Select-Object', 'Start-Process', 'Where-Object', 'Write-Error', 'Write-Host')
        Executables = @('msiexec.exe', 'SupportAssistUninstaller.exe')
        Policies = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Uninstall DellSupportAssist operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('Registry', 'Process', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
