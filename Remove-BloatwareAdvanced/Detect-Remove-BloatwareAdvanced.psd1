@{
    SchemaVersion = '1.0'
    Id = '09de6151-b9cc-5e2d-97b5-c908347223bd'
    Identity = @{
        PackageName = 'Remove-BloatwareAdvanced'
        ScriptName = 'Detect-Remove-BloatwareAdvanced'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects OEM bloatware and unnecessary pre-installed apps.'
        Authors = @('Jannik Reinhard')
        Source = 'Remove-BloatwareAdvanced/detection_detect-bloatware.ps1'
        Counterpart = 'Remove-BloatwareAdvanced/Remediate-Remove-BloatwareAdvanced.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('ForEach-Object', 'Get-AppxPackage', 'Write-Output', 'Write-Warning')
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
        Level = 'Low'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Appx')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
