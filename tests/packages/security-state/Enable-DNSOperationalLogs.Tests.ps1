BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Enable-DNSOperationalLogs/Detect-Enable-DNSOperationalLogs.ps1')
    . (Join-Path $PSScriptRoot '../../../scripts/Enable-DNSOperationalLogs/Remediate-Enable-DNSOperationalLogs.ps1')
}

Describe 'Enable-DNSOperationalLogs function contract' {
    BeforeEach {
        $logState = [pscustomobject]@{ IsEnabled = $false }
        $getLog = { [pscustomobject]@{ IsEnabled = $logState.IsEnabled } }
        $setLog = {
            param($name)
            $logState.IsEnabled = $true
        }
    }

    It 'detects an enabled DNS operational log as compliant' {
        $logState.IsEnabled = $true

        $result = Test-EnableDNSOperationalLogs -GetLog $getLog

        $result.Compliant | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'DNS Operational Log is enabled.'
        $result.State.IsEnabled | Should -BeTrue
        $result.Error | Should -BeNullOrEmpty
    }

    It 'detects a disabled DNS operational log as noncompliant' {
        $result = Test-EnableDNSOperationalLogs -GetLog $getLog

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'DNS Operational Log is disabled.'
        $result.State.IsEnabled | Should -BeFalse
    }

    It 'reports a missing event log dependency' {
        $result = Test-EnableDNSOperationalLogs -GetLog $null

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'DNS Operational Log detection failed.'
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports an event log query failure with truthful error evidence' {
        $result = Test-EnableDNSOperationalLogs -GetLog { throw 'event log query failed' }

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'event log query failed'
    }

    It 'does not save an already enabled event log' {
        $logState.IsEnabled = $true
        $logState | Add-Member -NotePropertyName SaveCalls -NotePropertyValue 0
        $set = {
            param($name)
            $logState.SaveCalls++
            $logState.IsEnabled = $true
        }

        $result = Repair-EnableDNSOperationalLogs -GetLog $getLog -SetLog $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'DNS Operational Log has been enabled.'
        $logState.SaveCalls | Should -Be 0
    }

    It 'enables the event log and detection converges to compliant' {
        $result = Repair-EnableDNSOperationalLogs -GetLog $getLog -SetLog $setLog
        $after = Test-EnableDNSOperationalLogs -GetLog $getLog

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.State.After.IsEnabled | Should -BeTrue
        $after.Compliant | Should -BeTrue
    }

    It 'returns failure and leaves state noncompliant when enabling fails' {
        $result = Repair-EnableDNSOperationalLogs -GetLog $getLog -SetLog { throw 'event log save failed' }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Failed to enable DNS Operational Log.'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'event log save failed'
        (Test-EnableDNSOperationalLogs -GetLog $getLog).Compliant | Should -BeFalse
    }

    It 'reports a missing setter dependency without changing the log' {
        $before = $logState.IsEnabled
        $result = Repair-EnableDNSOperationalLogs -GetLog $getLog -SetLog $null

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Error.Type | Should -Be 'MissingDependency'
        $logState.IsEnabled | Should -Be $before
    }

    It 'is idempotent after enabling the event log' {
        $first = Repair-EnableDNSOperationalLogs -GetLog $getLog -SetLog $setLog
        $second = Repair-EnableDNSOperationalLogs -GetLog $getLog -SetLog { throw 'setter should not be called' }

        $first.Changed | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.ExitCode | Should -Be 0
        $logState.IsEnabled | Should -BeTrue
    }
}
