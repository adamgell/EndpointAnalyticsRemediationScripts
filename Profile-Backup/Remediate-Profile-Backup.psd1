@{
    SchemaVersion = '1.0'
    Id = '819c9585-ff1e-5a0d-a648-5fe6e59a656a'
    Identity = @{
        PackageName = 'Profile-Backup'
        ScriptName = 'Remediate-Profile-Backup'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Downloads custom backup script and deploys to backup user profile to OneDrive.'
        Authors = @(
            'Joey Verlinden'
            'Andrew Taylor'
            'Florian Slazmann'
            'Jannik Reinhard'
        )
        Source = 'Profile-Backup/remediation_remediate-backup.ps1'
        Counterpart = 'Profile-Backup/Detect-Profile-Backup.ps1'
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
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @(
            'Add-Content'
            'Get-Date'
            'Invoke-WebRequest'
            'New-Item'
            'Out-Null'
            'set-Content'
            'Start-Process'
            'Test-Path'
            'Write-Error'
        )
        Executables = @(
            'Cscript.exe'
        )
        Policies = @()
        Endpoints = @(
            'https://raw.githubusercontent.com/andrew-s-taylor/public/main/Batch%20Scripts/backup.bat'
            'https://raw.githubusercontent.com/andrew-s-taylor/public/main/Batch%20Scripts/NEWrestore.bat'
            'https://raw.githubusercontent.com/andrew-s-taylor/public/main/Batch%20Scripts/run-invisible.vbs'
        )
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $false
        UserImpact = 'The script changes the Profile Backup state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Transfers reviewed local diagnostic or profile data to the configured external endpoint.'
    }
    Test = @{
        Categories = @(
            'File'
            'Rest'
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'InteractiveWindows'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $true
    }
}
