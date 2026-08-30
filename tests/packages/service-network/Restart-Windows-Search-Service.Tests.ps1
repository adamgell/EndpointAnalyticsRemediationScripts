Describe 'Restart-Windows-Search-Service package' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '../../../scripts/Restart-Windows-Search-Service'
        . (Join-Path $scriptPath 'Detect-Restart-Windows-Search-Service.ps1')
        . (Join-Path $scriptPath 'Remediate-Restart-Windows-Search-Service.ps1')
    }

    It 'detects WSearch running and preserves the existing operator message' {
        $decision = Get-RestartWindowsSearchServiceDetectionDecision -GetService {
            [pscustomobject]@{ Status = 'Running' }
        }

        $decision.Compliant | Should -BeTrue
        $decision.ExitCode | Should -Be 0
        $decision.Message | Should -Be 'Service is available and running'
        $decision.State | Should -Be 'Running'
    }

    It 'detects stopped or missing WSearch as noncompliant' {
        $stopped = Get-RestartWindowsSearchServiceDetectionDecision -GetService {
            [pscustomobject]@{ Status = 'Stopped' }
        }
        $missing = Get-RestartWindowsSearchServiceDetectionDecision -GetService { $null }

        $stopped.Compliant | Should -BeFalse
        $stopped.State | Should -Be 'Stopped'
        $stopped.ExitCode | Should -Be 1
        $missing.Compliant | Should -BeFalse
        $missing.State | Should -Be 'Missing'
        $missing.Error | Should -BeNullOrEmpty
    }

    It 'reports a service-provider failure with a nonzero decision' {
        $decision = Get-RestartWindowsSearchServiceDetectionDecision -GetService {
            throw 'Get-Service dependency failed.'
        }

        $decision.Compliant | Should -BeFalse
        $decision.State | Should -Be 'Error'
        $decision.ExitCode | Should -Be 1
        $decision.Message | Should -Match 'Get-Service dependency failed'
    }

    It 'restarts WSearch and proves convergence through a stateful fake' {
        $state = @{ Status = 'Stopped'; Restarts = 0 }
        $get = { [pscustomobject]@{ Status = $state.Status } }
        $restart = {
            $state.Restarts++
            $state.Status = 'Running'
        }

        $result = Invoke-RestartWindowsSearchServiceRemediation -GetService $get -RestartService $restart
        $decision = Get-RestartWindowsSearchServiceDetectionDecision -GetService $get
        $second = Invoke-RestartWindowsSearchServiceRemediation -GetService $get -RestartService $restart

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State | Should -Be 'Running'
        $state.Restarts | Should -Be 2
        $decision.Compliant | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.State | Should -Be 'Running'
    }

    It 'reports failed postconditions and restart failures truthfully' {
        $state = @{ Status = 'Stopped'; Calls = 0 }
        $failedPostcondition = Invoke-RestartWindowsSearchServiceRemediation `
            -GetService { [pscustomobject]@{ Status = $state.Status } } `
            -RestartService { $state.Calls++ }
        $failedOperation = Invoke-RestartWindowsSearchServiceRemediation `
            -GetService { [pscustomobject]@{ Status = $state.Status } } `
            -RestartService { throw 'Restart-Service dependency failed.' }

        $failedPostcondition.Succeeded | Should -BeFalse
        $failedPostcondition.ExitCode | Should -Be 1
        $failedPostcondition.State | Should -Be 'Stopped'
        $failedPostcondition.Error | Should -Match 'Expected service'
        $failedOperation.Succeeded | Should -BeFalse
        $failedOperation.ExitCode | Should -Be 1
        $failedOperation.Error | Should -Match 'Restart-Service dependency failed'
    }
}
