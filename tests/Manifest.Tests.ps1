BeforeAll {
    Import-Module "$PSScriptRoot/../tools/RepositoryCatalog.psm1" -Force
    $schemaPath = "$PSScriptRoot/../standards/ManifestSchema.psd1"
}

Describe 'Script manifest schema' {
    It 'accepts native boolean and numeric scalar types' {
        $result = Test-ScriptManifest `
            -Path "$PSScriptRoot/fixtures/manifests/ValidDetection.psd1" `
            -SchemaPath $schemaPath

        $result.Valid | Should -BeTrue
        $result.Errors | Should -BeNullOrEmpty
    }

    It 'rejects quoted booleans and coverage values' {
        $result = Test-ScriptManifest `
            -Path "$PSScriptRoot/fixtures/manifests/InvalidQuotedScalars.psd1" `
            -SchemaPath $schemaPath

        $result.Valid | Should -BeFalse
        $result.Errors | Should -Contain 'Runtime.RequiresElevation must be Boolean.'
        $result.Errors | Should -Contain 'Risk.Destructive must be Boolean.'
        $result.Errors | Should -Contain 'Test.CoverageFloor must be numeric.'
    }

    It 'rejects a Covered to PendingMigration transition' {
        Test-ManifestStatusTransition -Before Covered -After PendingMigration |
            Should -BeFalse
    }
}
