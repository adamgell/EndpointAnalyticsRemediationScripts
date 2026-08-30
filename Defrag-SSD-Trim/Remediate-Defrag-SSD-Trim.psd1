@{
    SchemaVersion = '1.0'
    Id = '333e8b26-7023-5e69-af30-7413a64182d4'
    Identity = @{
        PackageName = 'Defrag-SSD-Trim'
        ScriptName = 'Remediate-Defrag-SSD-Trim'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Runs TRIM on SSDs or defrag on HDDs and enables scheduled optimization.'
        Authors = @(
            'Jannik Reinhard'
        )
        Source = 'Defrag-SSD-Trim/remediation_optimize-disk.ps1'
        Counterpart = 'Defrag-SSD-Trim/Detect-Defrag-SSD-Trim.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'System'
        RequiresElevation = $true
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
            'Enable-ScheduledTask'
            'Get-Partition'
            'Get-PhysicalDisk'
            'Get-ScheduledTask'
            'Get-Volume'
            'Optimize-Volume'
            'Where-Object'
            'Write-Error'
            'Write-Output'
        )
        Executables = @()
        Policies = @()
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'Medium'
        Destructive = $false
        UserImpact = 'The script changes the Defrag SSD Trim state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @(
            'Service'
            'Native'
        )
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
