@{
    SchemaVersion = '1.0'
    Id = '3826ad9a-56b4-5b90-a6f8-18b7f7cd56f9'
    Identity = @{
        PackageName = 'Show-MessageCenterMessage'
        ScriptName = 'Remediate-Show-MessageCenterMessage'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Shows a toast notification with a message from a centrally managed message configuration.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Show-MessageCenterMessage/remediation_Show-MessageCenterMessageRemediation.ps1'
        Counterpart = 'Show-MessageCenterMessage/Detect-Show-MessageCenterMessage.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'User'
        RequiresElevation = $false
        SignatureCheck = 'NotRequired'
        SupportedWindows = @(
            'AllSupported'
        )
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Add-Content'
            'Invoke-RestMethod'
            'New-Item'
            'New-Object'
            'Out-Null'
            'Test-Path'
            'Write-Error'
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
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Show MessageCenterMessage state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'File'
            'Network'
            'Rest'
            'Ui'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
