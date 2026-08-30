@{
    SchemaVersion = '1.0'
    Id = '4317dd12-54dc-5265-9bcf-c91e5af8757d'
    Identity = @{
        PackageName = 'Remove-Silverlight'
        ScriptName = 'Detect-Remove-Silverlight'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Script detects the Microsoft Silverlight.'
        Authors = @(
            'Gerardo Hernandez'
        )
        Source = '0 - Template/Detect-Silverlight'
        Counterpart = 'Remove-Silverlight/Remediate-Remove-Silverlight.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $false
        SignatureCheck = 'NotRequired'
        SupportedWindows = @(
            'AllSupported'
        )
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-ChildItem'
            'Get-ItemProperty'
            'Select-Object'
            'Where-Object'
            'Write-Output'
        )
        Executables = @()
        Policies = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
        )
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
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
