@{
    SchemaVersion = '1.0'
    Id = '38f100bd-c3aa-5366-b937-6b77f92bd506'
    Identity = @{
        PackageName = 'Remove-Teams-Chat'
        ScriptName = 'Detect-Remove-Teams-Chat'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if Teams Chat is installed.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Remove Teams Chat/detection_detect-teams-chat.ps1'
        Counterpart = 'Remove-Teams-Chat/Remediate-Remove-Teams-Chat.ps1'
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Get-AppxPackage'
            'Get-AppxProvisionedPackage'
            'Where-Object'
            'write-host'
        )
        Executables = @()
        Policies = @()
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
            'Appx'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
