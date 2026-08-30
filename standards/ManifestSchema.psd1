@{
    SchemaVersion = '1.0'
    Enums = @{
        Role = @('Detection', 'Remediation')
        Architecture = @('x64')
        RunAs = @('System', 'User', 'Either')
        SignatureCheck = @('Required', 'NotRequired', 'Either')
        Reboot = @('None', 'Possible', 'Required')
        DetectionMode = @('Compliance', 'AlwaysRemediate', 'Inventory', 'NotApplicable')
        RiskLevel = @('Low', 'Medium', 'High', 'Critical')
        TestStatus = @('PendingMigration', 'Covered')
        IntegrationLevel = @('None', 'WindowsVm', 'InteractiveWindows', 'IntunePilot')
        TestCategory = @(
            'Registry'
            'Service'
            'File'
            'Process'
            'Network'
            'Rest'
            'Native'
            'Appx'
            'Ui'
            'Destructive'
        )
    }
    BooleanPaths = @(
        'Runtime.RequiresElevation'
        'Configuration.*.Required'
        'Configuration.*.Secret'
        'Risk.Destructive'
        'Test.RequiresIntunePilot'
        'Test.RequiresInteractiveUser'
    )
    NumericPaths = @('Test.CoverageFloor')
}
