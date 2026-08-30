@{
    SchemaVersion = '1.0'
    Id = 'e9648d10-c37e-5990-8494-d1b67d68032f'
    Identity = @{
        PackageName = 'Get-WH4BEnrolledMethods'
        ScriptName = 'Detect-Get-WH4BEnrolledMethods'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Get WH4BEnrolledMethods condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard', 'Marius Wyss')
        Source = 'Get-WH4BEnrolledMethods/detection_Get-WH4BEnrolledMethodsDetection.ps1'
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
        Policies = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{D6886603-9D2F-4EB2-B667-1971041FA96B}\$LoggedOnUserSID', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\AccountInfo\$LoggedOnUserSID')
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
