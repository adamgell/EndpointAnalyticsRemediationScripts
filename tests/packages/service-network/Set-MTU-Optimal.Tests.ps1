Describe 'Set-MTU-Optimal package' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '../../../scripts/Set-MTU-Optimal'
        . (Join-Path $scriptPath 'Detect-Set-MTU-Optimal.ps1')
        . (Join-Path $scriptPath 'Remediate-Set-MTU-Optimal.ps1')
    }

    It 'detects compliant physical and VPN interfaces while excluding loopback' {
        $interfaces = @(
            [pscustomobject]@{ InterfaceAlias = 'Ethernet'; InterfaceIndex = 4; NlMtu = 1500 }
            [pscustomobject]@{ InterfaceAlias = 'Corp VPN'; InterfaceIndex = 8; NlMtu = 1400 }
            [pscustomobject]@{ InterfaceAlias = 'Loopback Pseudo-Interface 1'; InterfaceIndex = 1; NlMtu = 576 }
        )

        $decision = Get-SetMtuOptimalDetectionDecision -GetInterfaces { $interfaces }

        $decision.Compliant | Should -BeTrue
        $decision.ExitCode | Should -Be 0
        $decision.Message | Should -Be 'Compliant - All adapters have optimal MTU'
        @($decision.Details).Count | Should -Be 2
        $decision.Details.InterfaceAlias | Should -Not -Contain 'Loopback Pseudo-Interface 1'
    }

    It 'detects an incorrect VPN MTU with a stable warning and remediation exit code' {
        $interfaces = @(
            [pscustomobject]@{ InterfaceAlias = 'Corp VPN'; InterfaceIndex = 8; NlMtu = 1500 }
        )

        $decision = Get-SetMtuOptimalDetectionDecision -GetInterfaces { $interfaces }

        $decision.Compliant | Should -BeFalse
        $decision.ExitCode | Should -Be 1
        $decision.State | Should -Be 'NonCompliant'
        @($decision.Warnings) | Should -Contain 'Not Compliant - Corp VPN: MTU is 1500 (expected: 1400)'
    }

    It 'reports missing or failing network-interface dependencies' {
        $missing = Get-SetMtuOptimalDetectionDecision -GetInterfaces {
            throw 'Get-NetIPInterface is unavailable.'
        }
        $malformed = Get-SetMtuOptimalDetectionDecision -GetInterfaces {
            [pscustomobject]@{ InterfaceAlias = 'Ethernet' }
        }

        $missing.Compliant | Should -BeFalse
        $missing.ExitCode | Should -Be 1
        $missing.State | Should -Be 'Error'
        $missing.Error | Should -Match 'Get-NetIPInterface is unavailable'
        $malformed.State | Should -Be 'Error'
        $malformed.Error | Should -Match 'without InterfaceAlias or NlMtu'
    }

    It 'changes mismatched interfaces and proves detection convergence' {
        $interfaces = @(
            [pscustomobject]@{ InterfaceAlias = 'Ethernet'; InterfaceIndex = 4; NlMtu = 1400 }
            [pscustomobject]@{ InterfaceAlias = 'Corp VPN'; InterfaceIndex = 8; NlMtu = 1500 }
        )
        $state = @{ SetCalls = @() }
        $get = { $interfaces }
        $set = {
            param($index, $target)
            $state.SetCalls += [pscustomobject]@{ Index = $index; Target = $target }
            ($interfaces | Where-Object { $_.InterfaceIndex -eq $index }).NlMtu = $target
        }

        $result = Invoke-SetMtuOptimalRemediation -GetInterfaces $get -SetInterface $set
        $decision = Get-SetMtuOptimalDetectionDecision -GetInterfaces $get
        $second = Invoke-SetMtuOptimalRemediation -GetInterfaces $get -SetInterface $set

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeTrue
        $result.ExitCode | Should -Be 0
        $result.State | Should -Be 'Compliant'
        @($state.SetCalls).Count | Should -Be 2
        $decision.Compliant | Should -BeTrue
        $second.Succeeded | Should -BeTrue
        $second.Changed | Should -BeFalse
        @($state.SetCalls).Count | Should -Be 2
    }

    It 'treats an endpoint with no active adapters as a safe no-op' {
        $result = Invoke-SetMtuOptimalRemediation -GetInterfaces { @() } -SetInterface {
            throw 'Set-NetIPInterface must not be called when no adapter is active.'
        }

        $result.Succeeded | Should -BeTrue
        $result.Changed | Should -BeFalse
        $result.ExitCode | Should -Be 0
        $result.State | Should -Be 'Compliant'
    }

    It 'returns a truthful failure for a set error and a failed postcondition' {
        $interfaces = @(
            [pscustomobject]@{ InterfaceAlias = 'Ethernet'; InterfaceIndex = 4; NlMtu = 1400 }
        )
        $setFailure = Invoke-SetMtuOptimalRemediation -GetInterfaces { $interfaces } -SetInterface {
            throw 'Set-NetIPInterface failed.'
        }
        $postconditionFailure = Invoke-SetMtuOptimalRemediation -GetInterfaces { $interfaces } -SetInterface { }

        $setFailure.Succeeded | Should -BeFalse
        $setFailure.ExitCode | Should -Be 1
        $setFailure.State | Should -Be 'Error'
        $setFailure.Error | Should -Match 'Set-NetIPInterface failed'
        $postconditionFailure.Succeeded | Should -BeFalse
        $postconditionFailure.ExitCode | Should -Be 1
        $postconditionFailure.State | Should -Be 'NonCompliant'
        $postconditionFailure.Error | Should -Match 'postcondition verification'
    }
}
