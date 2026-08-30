Describe 'Invoke-DnsClearCache package' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '../../../scripts/Invoke-DnsClearCache'
        . (Join-Path $scriptPath 'Detect-Invoke-DnsClearCache.ps1')
        . (Join-Path $scriptPath 'Remediate-Invoke-DnsClearCache.ps1')
    }

    It 'returns an always-remediate detection decision without touching the host' {
        $decision = Get-InvokeDnsClearCacheDetectionDecision

        $decision.Compliant | Should -BeFalse
        $decision.ExitCode | Should -Be 1
        $decision.Message | Should -Be 'Script will always be triggered'
        $decision.State | Should -Be 'AlwaysRemediate'
    }

    It 'clears through the injected Clear-DnsClientCache adapter and reports success' {
        $state = @{ Calls = 0 }
        $clear = {
            $state.Calls++
            'DNS client cache cleared.'
        }

        $result = Invoke-InvokeDnsClearCacheRemediation -ClearDns $clear

        $state.Calls | Should -Be 1
        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State | Should -Be 'Cleared'
        @($result.Output) | Should -Contain 'DNS client cache cleared.'
    }

    It 'reports a truthful nonzero result for a missing dependency' {
        $result = Invoke-InvokeDnsClearCacheRemediation -ClearDns {
            throw 'Clear-DnsClientCache is unavailable.'
        }

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State | Should -Be 'Unknown'
        $result.Message | Should -Match 'Clear-DnsClientCache is unavailable'
        $result.Error | Should -Match 'Clear-DnsClientCache is unavailable'
    }

    It 'reports a failed native operation and remains safe to retry' {
        $state = @{ Calls = 0 }
        $clear = {
            $state.Calls++
            if ($state.Calls -eq 1) {
                throw 'DNS cache provider failed.'
            }
            'cleared'
        }

        $failed = Invoke-InvokeDnsClearCacheRemediation -ClearDns $clear
        $retried = Invoke-InvokeDnsClearCacheRemediation -ClearDns $clear

        $failed.Succeeded | Should -BeFalse
        $failed.ExitCode | Should -Be 1
        $retried.Succeeded | Should -BeTrue
        $retried.State | Should -Be 'Cleared'
        $state.Calls | Should -Be 2
    }
}
