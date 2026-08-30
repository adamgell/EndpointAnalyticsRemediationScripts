@{
    SchemaVersion = '1.0'
    Id = '1e09f7d0-ef7c-5424-bb92-d5bd3d844ecc'
    Identity = @{
        PackageName = 'Show-MessageCenterMessage'
        ScriptName = 'Detect-Show-MessageCenterMessage'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects if there is a message to display to the user (via a centrally managed message file).'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Show-MessageCenterMessage/detection_Show-MessageCenterMessageDetection.ps1'
        Counterpart = 'Show-MessageCenterMessage/Remediate-Show-MessageCenterMessage.ps1'
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
            'Get-Content'
            'Invoke-RestMethod'
            'Test-Path'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @(
            'https://yourstorageaccount.blob.core.windows.net/messages/current-message.json'
        )
    }
    Configuration = @(
        @{
            Name = 'MessageConfigUrl'
            Required = $true
            Secret = $false
            Description = 'URL of the centrally managed message configuration.'
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
        Categories = @(
            'File'
            'Network'
            'Rest'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
