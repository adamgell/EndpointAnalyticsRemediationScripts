@{
    SchemaVersion = '1.0'
    Id = 'cf26b741-ff99-56f0-b20a-2b74318d0500'
    Identity = @{
        PackageName = 'Get-WH4BLastUsedMethod'
        ScriptName = 'Detect-Get-WH4BLastUsedMethod'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Get WH4BLastUsedMethod condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard', 'Marius Wyss')
        Source = 'Get-WH4BLastUsedMethod/detection_Get-WH4BLastUsedMethodDetection.ps1'
        Counterpart = ''
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'Inventory' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Get-ItemProperty', 'New-Item', 'Start-Transcript', 'Stop-Transcript', 'Test-Path', 'Write-Error', 'Write-Host', 'Write-Warning')
        Executables = @()
        Policies = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI')
        Endpoints = @()
    }
    Configuration = @(
        @{
            Name = 'LogDirSubFolderName'
            Required = $true
            Secret = $false
            Description = 'Subfolder name used for the Windows Hello transcript log.'
        }
    )
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'None; the script only observes current state.'
        Rollback = 'Not required; detection does not change endpoint state.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Registry', 'File')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
