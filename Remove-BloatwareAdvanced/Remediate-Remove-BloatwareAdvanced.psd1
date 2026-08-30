@{
    SchemaVersion = '1.0'
    Id = '6597f3cf-39f1-5510-b113-a87599c4028e'
    Identity = @{
        PackageName = 'Remove-BloatwareAdvanced'
        ScriptName = 'Remediate-Remove-BloatwareAdvanced'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Removes OEM bloatware and unnecessary pre-installed apps.'
        Authors = @('Jannik Reinhard')
        Source = 'Remove-BloatwareAdvanced/remediation_remove-bloatware.ps1'
        Counterpart = 'Remove-BloatwareAdvanced/Detect-Remove-BloatwareAdvanced.ps1'
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
        Cmdlets = @('Get-AppxPackage', 'Get-AppxProvisionedPackage', 'Remove-AppxPackage', 'Remove-AppxProvisionedPackage', 'Where-Object', 'Write-Error', 'Write-Output')
        Executables = @()
        Policies = @()
        Endpoints = @('king.com.BubbleWitch3Saga', 'king.com.CandyCrushSaga', 'king.com.CandyCrushSodaSaga')
    }
    Configuration = @(
        @{
            Name = 'Bloatware'
            Required = $false
            Secret = $false
            Description = 'Appx package names classified as removable bloatware.'
        }
    )
    Risk = @{
        Level = 'High'
        Destructive = $true
        UserImpact = 'The Remove BloatwareAdvanced operation can remove data, software, accounts, or configuration.'
        Rollback = 'Not available in the script; restore removed data from backup or reinstall removed components.'
        DataHandling = 'Reads local state and can delete or replace endpoint data selected by the script.'
    }
    Test = @{
        Categories = @('Appx', 'Destructive')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
