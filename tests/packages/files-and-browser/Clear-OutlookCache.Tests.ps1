BeforeAll {
    . (Join-Path $PSScriptRoot '../../../scripts/Clear-OutlookCache/Detect-Clear-OutlookCache.ps1')
    $remediationPath = Join-Path $PSScriptRoot `
        '../../../scripts/Clear-OutlookCache/Remediate-Clear-OutlookCache.ps1'
    . $remediationPath
}

Describe 'Clear-OutlookCache function contract' {
    BeforeEach {
        $outlookPath = Join-Path ([System.IO.Path]::GetTempPath()) 'OUTLOOK.EXE'
        $outlookState = [pscustomobject]@{
            Present = $true
            ObservationCalls = 0
            Launches = [System.Collections.Generic.List[object]]::new()
        }
        $testOutlookPath = {
            param([string]$Path)
            $outlookState.ObservationCalls++
            $outlookState.Present
        }
        $startOutlook = {
            param([string]$Path, [string[]]$Arguments)
            $launch = [pscustomobject]@{
                Path = $Path
                Arguments = @($Arguments)
            }
            $outlookState.Launches.Add($launch)
        }
    }

    It 'does not infer cache state from a present Outlook executable' {
        $result = Test-ClearOutlookCache `
            -TestOutlookPath $testOutlookPath `
            -OutlookPath $outlookPath

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.Message | Should -Be 'Outlook cache state is unknown; remediation is required.'
        $result.State.Kind | Should -Be 'Unknown'
        $result.State.OutlookExecutablePresent | Should -BeTrue
        $result.State.CacheState | Should -Be 'Unknown'
        $result.Error | Should -BeNullOrEmpty
    }

    It 'does not infer cache state from an absent Outlook executable' {
        $outlookState.Present = $false
        $result = Test-ClearOutlookCache `
            -TestOutlookPath $testOutlookPath `
            -OutlookPath $outlookPath

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'Unknown'
        $result.State.OutlookExecutablePresent | Should -BeFalse
        $result.State.CacheState | Should -Be 'Unknown'
        $result.Error | Should -BeNullOrEmpty
    }

    It 'reports a missing detection dependency' {
        $result = Test-ClearOutlookCache `
            -TestOutlookPath $null `
            -OutlookPath $outlookPath

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'DependencyMissing'
        $result.Error.Type | Should -Be 'MissingDependency'
    }

    It 'reports a detection dependency failure with the original error' {
        $result = Test-ClearOutlookCache `
            -TestOutlookPath { throw 'file query failed' } `
            -OutlookPath $outlookPath

        $result.Compliant | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'Error'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'file query failed'
    }

    It 'launches Outlook with the legacy clear-cache arguments' {
        $result = Invoke-ClearOutlookCacheRemediation `
            -TestOutlookPath $testOutlookPath `
            -StartOutlook $startOutlook `
            -OutlookPath $outlookPath

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.Message | Should -Be 'Outlook cache clear launched; cache convergence is deferred.'
        $result.State.Kind | Should -Be 'Deferred'
        $result.State.LaunchSucceeded | Should -BeTrue
        $result.State.After | Should -Be 'Unknown'
        $result.Error | Should -BeNullOrEmpty
        $outlookState.Launches.Count | Should -Be 1
        $outlookState.Launches[0].Path | Should -Be $outlookPath
        $outlookState.Launches[0].Arguments | Should -BeExactly @(
            '/cleanautocompletecache'
            '/recycle'
        )
    }

    It 'reports a failed launch without claiming a cache change' {
        $result = Invoke-ClearOutlookCacheRemediation `
            -TestOutlookPath $testOutlookPath `
            -StartOutlook { throw 'Start-Process failed' } `
            -OutlookPath $outlookPath

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'Error'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'Start-Process failed'
        $outlookState.Launches.Count | Should -Be 0
    }

    It 'invokes the launch again because cache convergence is not observable' {
        $first = Invoke-ClearOutlookCacheRemediation `
            -TestOutlookPath $testOutlookPath `
            -StartOutlook $startOutlook `
            -OutlookPath $outlookPath
        $second = Invoke-ClearOutlookCacheRemediation `
            -TestOutlookPath $testOutlookPath `
            -StartOutlook $startOutlook `
            -OutlookPath $outlookPath

        $first.Succeeded | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $first.State.Kind | Should -Be 'Deferred'
        $second.State.Kind | Should -Be 'Deferred'
        $outlookState.Launches.Count | Should -Be 2
    }

    It 'reports a failing detection observation without launching Outlook' {
        $result = Invoke-ClearOutlookCacheRemediation `
            -TestOutlookPath { throw 'observation failed' } `
            -StartOutlook $startOutlook `
            -OutlookPath $outlookPath

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'Error'
        $result.Error.Type | Should -Be 'DependencyFailure'
        $result.Error.Message | Should -Match 'observation failed'
        $outlookState.Launches.Count | Should -Be 0
    }

    It 'reports missing remediation dependencies without launching Outlook' {
        $result = Invoke-ClearOutlookCacheRemediation `
            -TestOutlookPath $testOutlookPath `
            -StartOutlook $null `
            -OutlookPath $outlookPath

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 1
        $result.State.Kind | Should -Be 'DependencyMissing'
        $result.Error.Type | Should -Be 'MissingDependency'
        $outlookState.Launches.Count | Should -Be 0
    }

    It 'rejects a relative executable path before invoking dependencies' {
        $result = Invoke-ClearOutlookCacheRemediation `
            -TestOutlookPath $testOutlookPath `
            -StartOutlook $startOutlook `
            -OutlookPath 'OUTLOOK.EXE'

        $result.Succeeded | Should -BeFalse
        $result.Changed | Should -BeFalse
        $result.State.Kind | Should -Be 'SafetyRejected'
        $result.Error.Type | Should -Be 'InvalidPath'
        $outlookState.ObservationCalls | Should -Be 0
        $outlookState.Launches.Count | Should -Be 0
    }
}
