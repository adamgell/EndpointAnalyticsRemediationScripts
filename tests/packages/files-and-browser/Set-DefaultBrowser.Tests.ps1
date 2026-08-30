BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Set-DefaultBrowser/Detect-Set-DefaultBrowser.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Set-DefaultBrowser/Remediate-Set-DefaultBrowser.ps1')

    $testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('Set-DefaultBrowser-' + [guid]::NewGuid().ToString('N'))
    New-Item -Path $testRoot -ItemType Directory -Force | Out-Null
}

AfterAll {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Describe 'Set-DefaultBrowser function contract' {
    BeforeEach {
        $browserState = [pscustomobject]@{ ProgId = 'ChromeHTML'; SetCalls = 0; WriteCalls = 0 }
        $xmlPath = Join-Path $testRoot ('DefaultAssociations-' + [guid]::NewGuid().ToString('N') + '.xml')
        $policyPath = Join-Path $testRoot ('Policy-' + [guid]::NewGuid().ToString('N'))
        $getDefaultBrowser = { [pscustomobject]@{ ProgId = $browserState.ProgId } }
        $testFile = { param([string]$Path) Test-Path -LiteralPath $Path }
        $writeAssociations = {
            param([string]$Path, [string]$Content)
            $browserState.WriteCalls++
            Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
        }
        $setPolicy = {
            param([string]$Path, [string]$AssociationPath)
            $browserState.SetCalls++
        }
        $signIn = {
            $browserState.ProgId = 'MSEdgeHTM'
        }
    }

    It 'detects Edge as compliant' {
        $browserState.ProgId = 'MSEdgeHTM'
        $result = Test-SetDefaultBrowser -GetDefaultBrowser $getDefaultBrowser

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Compliant - Default browser is set to MSEdgeHTM'
        $result.State.ProgId | Should -Be 'MSEdgeHTM'
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects a different browser as noncompliant' {
        $result = Test-SetDefaultBrowser -GetDefaultBrowser $getDefaultBrowser

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant - Default browser is ChromeHTML (expected: MSEdgeHTM)'
        $result.State.ProgId | Should -Be 'ChromeHTML'
    }

    It 'detects a missing UserChoice value as noncompliant' {
        $browserState.ProgId = $null
        $result = Test-SetDefaultBrowser -GetDefaultBrowser $getDefaultBrowser

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Not Compliant - Default browser is  (expected: MSEdgeHTM)'
        $result.State.Kind | Should -Be 'Missing'
    }

    It 'reports a missing registry dependency' {
        $result = Test-SetDefaultBrowser -GetDefaultBrowser $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'DependencyMissing'
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports registry query failures with truthful error evidence' {
        $result = Test-SetDefaultBrowser -GetDefaultBrowser { throw 'UserChoice query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'Error'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'UserChoice query failed'
    }

    It 'does not write policy when Edge is already the default browser' {
        $browserState.ProgId = 'MSEdgeHTM'
        $result = Invoke-SetDefaultBrowserRemediation `
            -GetDefaultBrowser $getDefaultBrowser `
            -WriteAssociations $writeAssociations `
            -SetPolicy $setPolicy `
            -TestFile $testFile `
            -XmlPath $xmlPath `
            -PolicyPath $policyPath

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.State.Kind | Should -Be 'AlreadyCompliant'
        $browserState.SetCalls | Should -Be 0
        $browserState.WriteCalls | Should -Be 0
        (Test-Path -LiteralPath $xmlPath) | Should -BeFalse
    }

    It 'writes associations and policy, then defers UserChoice convergence until sign-in' {
        $result = Invoke-SetDefaultBrowserRemediation `
            -GetDefaultBrowser $getDefaultBrowser `
            -WriteAssociations $writeAssociations `
            -SetPolicy $setPolicy `
            -TestFile $testFile `
            -XmlPath $xmlPath `
            -PolicyPath $policyPath

        $expectedMessage = 'Default browser policy has been applied; ' +
        'Microsoft Edge will become the default browser after sign-in'
        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be $expectedMessage
        $result.State.Kind | Should -Be 'PendingSignIn'
        $result.State.Before.ProgId | Should -Be 'ChromeHTML'
        $result.State.DeferredUntilSignIn | Should -BeTrue
        $result.State.PolicyApplied | Should -BeTrue
        $result.State.PolicyPath | Should -Be $policyPath
        $result.State.XmlPath | Should -Be $xmlPath
        $browserState.ProgId | Should -Be 'ChromeHTML'
        $browserState.SetCalls | Should -Be 1
        $browserState.WriteCalls | Should -Be 1
        (Test-Path -LiteralPath $xmlPath) | Should -BeTrue

        & $signIn
        $afterSignIn = Test-SetDefaultBrowser -GetDefaultBrowser $getDefaultBrowser
        $afterSignIn.Compliant | Should -BeTrue
        $afterSignIn.State.ProgId | Should -Be 'MSEdgeHTM'
    }

    It 'returns a truthful failure when associations postcondition fails' {
        $result = Invoke-SetDefaultBrowserRemediation `
            -GetDefaultBrowser $getDefaultBrowser `
            -WriteAssociations $writeAssociations `
            -SetPolicy $setPolicy `
            -TestFile { param([string]$Path) $false } `
            -XmlPath $xmlPath `
            -PolicyPath $policyPath

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'PostconditionFailed'
        $result.Error.Type | Should -Be 'PostconditionFailure'
        $browserState.SetCalls | Should -Be 0
    }

    It 'returns a truthful failure when the policy setter fails' {
        $result = Invoke-SetDefaultBrowserRemediation `
            -GetDefaultBrowser $getDefaultBrowser `
            -WriteAssociations $writeAssociations `
            -SetPolicy { throw 'policy setter failed' } `
            -TestFile $testFile `
            -XmlPath $xmlPath `
            -PolicyPath $policyPath

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'Error'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'policy setter failed'
        (Test-Path -LiteralPath $xmlPath) | Should -BeTrue
    }

    It 'does not claim convergence when the policy setter returns false' {
        $result = Invoke-SetDefaultBrowserRemediation `
            -GetDefaultBrowser $getDefaultBrowser `
            -WriteAssociations $writeAssociations `
            -SetPolicy { $browserState.SetCalls++; $false } `
            -TestFile $testFile `
            -XmlPath $xmlPath `
            -PolicyPath $policyPath

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'PostconditionFailed'
        $result.Error.Type | Should -Be 'PostconditionFailure'
        $result.Error.Message | Should -Match 'policy setter'
        (Test-Path -LiteralPath $xmlPath) | Should -BeTrue
    }

    It 'keeps policy remediation idempotent after sign-in convergence' {
        $result = Invoke-SetDefaultBrowserRemediation `
            -GetDefaultBrowser $getDefaultBrowser `
            -WriteAssociations $writeAssociations `
            -SetPolicy $setPolicy `
            -TestFile $testFile `
            -XmlPath $xmlPath `
            -PolicyPath $policyPath

        & $signIn
        $second = Invoke-SetDefaultBrowserRemediation `
            -GetDefaultBrowser $getDefaultBrowser `
            -WriteAssociations { throw 'writer should not be called' } `
            -SetPolicy { throw 'setter should not be called' } `
            -TestFile $testFile `
            -XmlPath $xmlPath `
            -PolicyPath $policyPath

        $result.State.Kind | Should -Be 'PendingSignIn'
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $second.State.Kind | Should -Be 'AlreadyCompliant'
        $browserState.SetCalls | Should -Be 1
    }

    It 'returns a truthful failure when writing the associations file fails' {
        $result = Invoke-SetDefaultBrowserRemediation `
            -GetDefaultBrowser $getDefaultBrowser `
            -WriteAssociations { throw 'association write failed' } `
            -SetPolicy $setPolicy `
            -TestFile $testFile `
            -XmlPath $xmlPath `
            -PolicyPath $policyPath

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'Error'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'association write failed'
        $browserState.SetCalls | Should -Be 0
    }

    It 'reports missing remediation dependencies without writing a file' {
        $result = Invoke-SetDefaultBrowserRemediation `
            -GetDefaultBrowser $getDefaultBrowser `
            -WriteAssociations $writeAssociations `
            -SetPolicy $null `
            -TestFile $testFile `
            -XmlPath $xmlPath `
            -PolicyPath $policyPath

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
        (Test-Path -LiteralPath $xmlPath) | Should -BeFalse
        $browserState.WriteCalls | Should -Be 0
    }

    It 'rejects a relative associations path before invoking dependencies' {
        $result = Invoke-SetDefaultBrowserRemediation `
            -GetDefaultBrowser $getDefaultBrowser `
            -WriteAssociations { throw 'should not run' } `
            -SetPolicy { throw 'should not run' } `
            -TestFile $testFile `
            -XmlPath 'DefaultAssociations.xml' `
            -PolicyPath $policyPath

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.State.Kind | Should -Be 'SafetyRejected'
        $result.Error.Type | Should -Be 'InvalidPath'
    }
}
