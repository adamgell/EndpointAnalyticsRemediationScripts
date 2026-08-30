@{
    SchemaVersion = '1.0'
    Id = '075994d4-5d0c-5527-b910-06a145f64335'
    Identity = @{
        PackageName = 'Run-ConnectionTest'
        ScriptName = 'Detect-Run-ConnectionTest'
        Role = 'Detection'
        Version = '1.0.0'
        Description = 'Detects the Run ConnectionTest condition.'
        Authors = @('Joey Verlinden', 'Andrew Taylor', 'Florian Slazmann', 'Jannik Reinhard')
        Source = 'Run-ConnectionTest/detection_Run-ConnectionTestDetection.ps1'
        Counterpart = ''
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
    Behavior = @{ DetectionMode = 'Compliance' }
    Dependencies = @{
        Modules = @()
        Cmdlets = @('ForEach-Object', 'Test-NetConnection', 'Write-Host')
        Executables = @()
        Policies = @()
        Endpoints = @('aadcdn.msauth.net', 'activation-v2.sls.microsoft.com', 'activation.sls.microsoft.com', 'adl.windows.com', 'approdimedatahotfix.azureedge.net', 'approdimedatapri.azureedge.net', 'approdimedatasec.azureedge.net', 'autologon.microsoftazuread-sso.com', 'config.office.com', 'cs.dds.microsoft.com', 'displaycatalog.md.mp.microsoft.com', 'displaycatalog.mp.microsoft.com', 'dl.delivery.mp.microsoft.com', 'ekcert.spserv.microsoft.com', 'ekop.intel.com', 'emdl.ws.microsoft.com', 'enrollment.manage.microsoft.com', 'enterpriseenrollment-s.manage.microsoft.com', 'enterpriseEnrollment.manage.microsoft.com', 'enterpriseregistration.windows.net', 'euprodimedatahotfix.azureedge.net', 'euprodimedatapri.azureedge.net', 'euprodimedatasec.azureedge.net', 'fe2cr.update.microsoft.com', 'fef.msuc03.manage.microsoft.com', 'ftpm.amd.com', 'go.microsoft.com', 'graph.windows.net', 'licensing.md.mp.microsoft.com', 'licensing.mp.microsoft.com', 'login.live.com', 'login.microsoftonline.com', 'm.manage.microsoft.com', 'mam.manage.microsoft.com', 'manage.microsoft.com', 'naprodimedatahotfix.azureedge.net', 'naprodimedatapri.azureedge.net', 'naprodimedatasec.azureedge.net', 'oca.telemetry.microsoft.com', 'portal.manage.microsoft.com', 'powershellgallery.com', 'purchase.md.mp.microsoft.com', 'purchase.mp.microsoft.com', 'settings-win.data.microsoft.com', 'update.microsoft.com', 'v10.vortex-win.data.microsoft.com', 'v10c.events.data.microsoft.com', 'validation-v2.sls.microsoft.com', 'validation.sls.microsoft.com', 'watson.telemetry.microsoft.com', 'www.msftconnecttest.com', 'ztd.dds.microsoft.com')
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
        Categories = @('Network')
        Status = 'PendingMigration'
        CoverageFloor = 0.0
        IntegrationLevel = 'WindowsVm'
        RequiresIntunePilot = $false
        RequiresInteractiveUser = $false
    }
}
