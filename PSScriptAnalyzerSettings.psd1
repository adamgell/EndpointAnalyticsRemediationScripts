@{
    Severity = @('Error', 'Warning')
    IncludeRules = @(
        'PSAvoidUsingCmdletAliases'
        'PSUseApprovedVerbs'
        'PSAvoidUsingInvokeExpression'
        'PSUseConsistentIndentation'
        'PSUseConsistentWhitespace'
        'PSPlaceOpenBrace'
        'PSPlaceCloseBrace'
        'PSAvoidLongLines'
    )
    # Exact 120-column exceptions are enforced by FoundationStyle tests and evidence.
    ExcludeRules = @('PSAvoidLongLines')
    Rules = @{
        PSAvoidUsingCmdletAliases = @{ allowlist = @() }
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind = 'space'
        }
        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckPipe = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator = $true
            CheckParameter = $false
            IgnoreAssignmentOperatorInsideHashTable = $false
        }
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace = @{
            Enable = $true
            NoEmptyLineBefore = $false
            IgnoreOneLineBlock = $true
            NewLineAfter = $true
        }
        PSAvoidLongLines = @{
            Enable = $true
            MaximumLineLength = 120
        }
    }
}
