Describe 'Clear-DnsCache package' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '../../../scripts/Clear-DnsCache'
        . (Join-Path $scriptPath 'Detect-Clear-DnsCache.ps1')
        . (Join-Path $scriptPath 'Remediate-Clear-DnsCache.ps1')
    }

    It 'returns an always-remediate detection decision without touching the host' {
        $decision = Get-ClearDnsCacheDetectionDecision

        $decision.Compliant | Should -BeFalse
        $decision.ExitCode | Should -Be 1
        $decision.Message | Should -Be 'Script will always be triggered'
        $decision.State | Should -Be 'AlwaysRemediate'
    }

    It 'clears through the injected native adapter and reports success' {
        $state = @{ Calls = 0 }
        $flush = {
            $state.Calls++
            'Successfully flushed the DNS Resolver Cache.'
        }

        $result = Invoke-ClearDnsCacheRemediation -FlushDns $flush

        $state.Calls | Should -Be 1
        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State | Should -Be 'Cleared'
        @($result.Output) | Should -Contain 'Successfully flushed the DNS Resolver Cache.'
    }

    It 'reports a truthful nonzero result when ipconfig is unavailable or fails' {
        $result = Invoke-ClearDnsCacheRemediation -FlushDns {
            throw 'ipconfig.exe is unavailable.'
        }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State | Should -Be 'Unknown'
        $result.Message | Should -Match 'ipconfig.exe is unavailable'
        $result.Error | Should -Match 'ipconfig.exe is unavailable'
    }

    It 'is safe to invoke repeatedly because cache flush is idempotent' {
        $state = @{ Calls = 0 }
        $flush = { $state.Calls++; 'flushed' }

        $first = Invoke-ClearDnsCacheRemediation -FlushDns $flush
        $second = Invoke-ClearDnsCacheRemediation -FlushDns $flush

        $first.Succeeded | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.State | Should -Be 'Cleared'
        $state.Calls | Should -Be 2
    }
}
