Describe 'Restart-Service-Generic package' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '../../../scripts/Restart-Service-Generic'
        . (Join-Path $scriptPath 'Detect-Restart-Service-Generic.ps1')
        . (Join-Path $scriptPath 'Remediate-Restart-Service-Generic.ps1')
    }

    It 'detects a running service as compliant with the stable message' {
        $decision = Get-RestartServiceGenericDetectionDecision -ServiceName 'Example' -GetService {
            [pscustomobject]@{ Status = 'Running' }
        }

        $decision.Compliant | Should -BeTrue
        $decision.ExitCode | Should -Be 0
        $decision.Message | Should -Be 'Service is available and running'
        $decision.State | Should -Be 'Running'
    }

    It 'detects a stopped service as noncompliant rather than treating existence as compliance' {
        $decision = Get-RestartServiceGenericDetectionDecision -ServiceName 'Example' -GetService {
            [pscustomobject]@{ Status = 'Stopped' }
        }

        $decision.Compliant | Should -BeFalse
        $decision.ExitCode | Should -Be 1
        $decision.Message | Should -Be 'Service is not there/running'
        $decision.State | Should -Be 'Stopped'
    }

    It 'distinguishes a missing service from a service-provider failure' {
        $missing = Get-RestartServiceGenericDetectionDecision -ServiceName 'Missing' -GetService { $null }
        $failed = Get-RestartServiceGenericDetectionDecision -ServiceName 'Example' -GetService {
            throw 'Service provider unavailable.'
        }

        $missing.State | Should -Be 'Missing'
        $missing.Error | Should -BeNullOrEmpty
        $missing.ExitCode | Should -Be 1
        $failed.State | Should -Be 'Error'
        $failed.Error | Should -Match 'Service provider unavailable'
        $failed.ExitCode | Should -Be 1
    }

    It 'restarts a stopped service and proves convergence with a stateful fake' {
        $state = @{ Status = 'Stopped'; Restarts = 0 }
        $get = { [pscustomobject]@{ Status = $state.Status } }
        $restart = {
            $state.Restarts++
            $state.Status = 'Running'
        }

        $result = Invoke-RestartServiceGenericRemediation `
            -ServiceName 'Example' `
            -GetService $get `
            -RestartService $restart
        $decision = Get-RestartServiceGenericDetectionDecision -ServiceName 'Example' -GetService $get
        $second = Invoke-RestartServiceGenericRemediation `
            -ServiceName 'Example' `
            -GetService $get `
            -RestartService $restart

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State | Should -Be 'Running'
        $state.Restarts | Should -Be 2
        $decision.Compliant | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.State | Should -Be 'Running'
    }

    It 'returns a failed postcondition when restart does not start the service' {
        $state = @{ Status = 'Stopped' }
        $result = Invoke-RestartServiceGenericRemediation -ServiceName 'Example' `
            -GetService { [pscustomobject]@{ Status = $state.Status } } `
            -RestartService { }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 1
        $result.State | Should -Be 'Stopped'
        $result.Error | Should -Match 'Expected service'
    }

    It 'returns a truthful nonzero result for restart failure and handles a retry' {
        $state = @{ Status = 'Stopped'; Calls = 0 }
        $get = { [pscustomobject]@{ Status = $state.Status } }
        $restart = {
            $state.Calls++
            if ($state.Calls -eq 1) {
                throw 'Restart provider failed.'
            }
            $state.Status = 'Running'
        }

        $failed = Invoke-RestartServiceGenericRemediation `
            -ServiceName 'Example' `
            -GetService $get `
            -RestartService $restart
        $retried = Invoke-RestartServiceGenericRemediation `
            -ServiceName 'Example' `
            -GetService $get `
            -RestartService $restart

        $failed.Succeeded | Should -BeFalse
        $failed.ExitCode | Should -Be 1
        $failed.Error | Should -Match 'Restart provider failed'
        $retried.Succeeded | Should -BeTrue
        $retried.State | Should -Be 'Running'
        $state.Calls | Should -Be 2
    }
}