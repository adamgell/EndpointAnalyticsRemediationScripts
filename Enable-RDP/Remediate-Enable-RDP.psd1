@{
    SchemaVersion = '1.0'
    Id = '84cdfe71-0d30-53aa-a750-d728c610c41d'
    Identity = @{
        PackageName = 'Enable-RDP'
        ScriptName = 'Remediate-Enable-RDP'
        Role = 'Remediation'
        Version = '1.0.0'
        Description = 'Remediates the Enable RDP condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Enable-RDP/remediation_Enable-RDPRemedaiton.ps1'
        Counterpart = 'Enable-RDP/Detect-Enable-RDP.ps1'
    }
    Runtime = @{
        PowerShellVersion = '5.1'
        Architecture = 'x64'
        RunAs = 'Either'
        RequiresElevation = $true
        SignatureCheck = 'Either'
        SupportedWindows = @('AllSupported')
        Reboot = 'None'
    }
    Behavior = @{ DetectionMode = 'NotApplicable' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('Add-LocalGroupMember', 'Get-LocalGroupMember', 'Get-WmiObject', 'Set-ItemProperty')
        Executables = @()
        Policies = @('HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\')
        Endpoints = @()
    }
    Configuration = @()
    Risk = @{
        Level = 'High'
        Destructive = $false
        UserImpact = 'The script changes the Enable RDP state and can briefly affect users or services.'
        Rollback = 'Restore the prior endpoint configuration; the script does not automate rollback.'
        DataHandling = 'Reads or changes local endpoint state; the manifest stores no endpoint data.'
    }
    Test = @{
        Categories = @('Registry', 'Native')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
