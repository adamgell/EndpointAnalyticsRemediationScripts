Describe 'Restart-Windows-Update-Service package' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '../../../scripts/Restart-Windows-Update-Service'
        . (Join-Path $scriptPath 'Detect-Restart-Windows-Update-Service.ps1')
        . (Join-Path $scriptPath 'Remediate-Restart-Windows-Update-Service.ps1')
    }

    It 'detects Windows Update running with the stable compliant result' {
        $decision = Get-RestartWindowsUpdateServiceDetectionDecision -GetService {
            [pscustomobject]@{ Status = 'Running' }
        }

        $decision.Compliant | Should -BeTrue
        $decision.ExitCode | Should -Be 0
        $decision.Message | Should -Be 'Service is available and running'
        $decision.State | Should -Be 'Running'
    }

    It 'detects stopped and missing Windows Update as noncompliant' {
        $stopped = Get-RestartWindowsUpdateServiceDetectionDecision -GetService {
            [pscustomobject]@{ Status = 'Stopped' }
        }
        $missing = Get-RestartWindowsUpdateServiceDetectionDecision -GetService { $null }

        $stopped.Compliant | Should -BeFalse
        $stopped.State | Should -Be 'Stopped'
        $stopped.ExitCode | Should -Be 1
        $missing.Compliant | Should -BeFalse
        $missing.State | Should -Be 'Missing'
        $missing.Error | Should -BeNullOrEmpty
    }

    It 'returns a dependency failure as a truthful nonzero decision' {
        $decision = Get-RestartWindowsUpdateServiceDetectionDecision -GetService {
            throw 'Windows Update service provider failed.'
        }

        $decision.Compliant | Should -BeFalse
        $decision.State | Should -Be 'Error'
        $decision.ExitCode | Should -Be 1
        $decision.Message | Should -Match 'Windows Update service provider failed'
    }

    It 'restarts Windows Update and proves convergence using stateful fakes' {
        $state = @{ Status = 'Stopped'; Restarts = 0 }
        $get = { [pscustomobject]@{ Status = $state.Status } }
        $restart = {
            $state.Restarts++
            $state.Status = 'Running'
        }

        $result = Invoke-RestartWindowsUpdateServiceRemediation -GetService $get -RestartService $restart
        $decision = Get-RestartWindowsUpdateServiceDetectionDecision -GetService $get
        $second = Invoke-RestartWindowsUpdateServiceRemediation -GetService $get -RestartService $restart

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State | Should -Be 'Running'
        $state.Restarts | Should -Be 2
        $decision.Compliant | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.State | Should -Be 'Running'
    }

    It 'reports failed postconditions and operation errors without claiming success' {
        $state = @{ Status = 'Stopped' }
        $failedPostcondition = Invoke-RestartWindowsUpdateServiceRemediation `
            -GetService { [pscustomobject]@{ Status = $state.Status } } `
            -RestartService { }
        $failedOperation = Invoke-RestartWindowsUpdateServiceRemediation `
            -GetService { [pscustomobject]@{ Status = $state.Status } } `
            -RestartService { throw 'Restart-Service failed.' }

        $failedPostcondition.Succeeded | Should -BeFalse
        $failedPostcondition.ExitCode | Should -Be 1
        $failedPostcondition.State | Should -Be 'Stopped'
        $failedPostcondition.Error | Should -Match 'Expected service'
        $failedOperation.Succeeded | Should -BeFalse
        $failedOperation.ExitCode | Should -Be 1
        $failedOperation.Error | Should -Match 'Restart-Service failed'
    }
}
