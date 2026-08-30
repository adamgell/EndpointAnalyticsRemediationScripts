Describe 'Set-Service-Generic package' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '../../../scripts/Set-Service-Generic'
        . (Join-Path $scriptPath 'Detect-Set-Service-Generic.ps1')
        . (Join-Path $scriptPath 'Remediate-Set-Service-Generic.ps1')
    }

    It 'detects a service property that matches the configured value' {
        $decision = Get-SetServiceGenericDetectionDecision -ServiceName 'Example' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService {
            [pscustomobject]@{ StartType = 'Automatic' }
        }

        $decision.Compliant | Should -BeTrue
        $decision.ExitCode | Should -Be 0
        $decision.Message | Should -Be 'Service is available and correctly configured'
        $decision.State | Should -Be 'Configured'
    }

    It 'detects missing, absent-property, and mismatched service state' {
        $missing = Get-SetServiceGenericDetectionDecision -ServiceName 'Missing' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService { $null }
        $absent = Get-SetServiceGenericDetectionDecision -ServiceName 'Example' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService {
            [pscustomobject]@{ Status = 'Running' }
        }
        $mismatch = Get-SetServiceGenericDetectionDecision -ServiceName 'Example' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService {
            [pscustomobject]@{ StartType = 'Manual' }
        }

        $missing.Compliant | Should -BeFalse
        $missing.State | Should -Be 'Missing'
        $absent.Compliant | Should -BeFalse
        $absent.State | Should -Be 'MissingOption'
        $mismatch.Compliant | Should -BeFalse
        $mismatch.State | Should -Be 'Misconfigured'
        $missing.ExitCode | Should -Be 1
        $absent.ExitCode | Should -Be 1
        $mismatch.ExitCode | Should -Be 1
    }

    It 'returns a truthful nonzero decision when the service dependency fails' {
        $decision = Get-SetServiceGenericDetectionDecision -ServiceName 'Example' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService {
            throw 'Get-Service failed.'
        }

        $decision.Compliant | Should -BeFalse
        $decision.State | Should -Be 'Error'
        $decision.ExitCode | Should -Be 1
        $decision.Error | Should -Match 'Get-Service failed'
    }

    It 'sets a mismatched property and proves convergence with a stateful fake' {
        $state = [pscustomobject]@{ StartType = 'Manual' }
        $setCalls = @{ Count = 0 }
        $get = { $state }
        $set = {
            param($name, $option, $value)
            $setCalls.Count++
            $state.$option = $value
        }

        $result = Invoke-SetServiceGenericRemediation -ServiceName 'Example' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService $get -SetService $set
        $decision = Get-SetServiceGenericDetectionDecision -ServiceName 'Example' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService $get
        $second = Invoke-SetServiceGenericRemediation -ServiceName 'Example' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService $get -SetService $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State | Should -Be 'Configured'
        $setCalls.Count | Should -Be 1
        $decision.Compliant | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $setCalls.Count | Should -Be 1
    }

    It 'reports failed set operations and failed postconditions' {
        $state = [pscustomobject]@{ StartType = 'Manual' }
        $failed = Invoke-SetServiceGenericRemediation -ServiceName 'Example' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService { $state } -SetService {
            throw 'Set-Service failed.'
        }
        $postcondition = Invoke-SetServiceGenericRemediation -ServiceName 'Example' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService { $state } -SetService { }

        $failed.Succeeded | Should -BeFalse
        $failed.Changed | Should -BeFalse
        $failed.ExitCode | Should -Be 1
        $failed.State | Should -Be 'Error'
        $failed.Error | Should -Match 'Set-Service failed'
        $postcondition.Succeeded | Should -BeFalse
        $postcondition.Changed | Should -BeTrue
        $postcondition.ExitCode | Should -Be 1
        $postcondition.State | Should -Be 'Misconfigured'
        $postcondition.Error | Should -Match 'Expected'
    }

    It 'fails safely when the target service is missing' {
        $result = Invoke-SetServiceGenericRemediation -ServiceName 'Missing' `
            -ServiceOption 'StartType' -ServiceOptionValue 'Automatic' -GetService { $null } -SetService {
            throw 'Set-Service must not be called for a missing service.'
        }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State | Should -Be 'Missing'
        $result.Error | Should -Match 'was not found'
    }
}
