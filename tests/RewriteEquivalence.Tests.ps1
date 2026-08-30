BeforeAll {
    Import-Module "$PSScriptRoot/../tools/RewriteEquivalence.psm1" -Force
    $fixtureRoot = "$PSScriptRoot/fixtures/rewrite"
    $wrapperPath = "$PSScriptRoot/../tools/Test-PowerShellRewrite.ps1"
    $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
    $foundationSymbolMap = Import-PowerShellDataFile -Path (Join-Path $repositoryRoot 'evidence/foundation/SymbolRenames.psd1')

    function Invoke-CatalogFunctionReferenceGate {
        param(
            [Parameter(Mandatory)] [string] $Root,
            [Parameter(Mandatory)] [string] $CandidateSource
        )

        $tools = Join-Path $Root 'tools'
        $catalog = Join-Path $Root 'Catalog'
        New-Item -ItemType Directory -Path $tools, $catalog -Force | Out-Null
        Copy-Item -LiteralPath "$PSScriptRoot/../tools/RewriteEquivalence.psm1" -Destination $tools
        Copy-Item -LiteralPath $wrapperPath -Destination $tools

        $catalogPath = Join-Path $catalog 'Script.ps1'
        @"
function IsMember {}
IsMember
$CandidateSource
"@ | Set-Content -LiteralPath $catalogPath -Encoding utf8
        & git -C $Root init --quiet
        & git -C $Root config core.autocrlf false
        & git -C $Root config user.email 'rewrite-gate@example.invalid'
        & git -C $Root config user.name 'Rewrite Gate Test'
        & git -C $Root add Catalog
        & git -C $Root commit --quiet -m baseline
        $baseRevision = (& git -C $Root rev-parse HEAD).Trim()

        @"
function Test-GroupMembership {}
Test-GroupMembership
$CandidateSource
"@ | Set-Content -LiteralPath $catalogPath -Encoding utf8
        $pathMap = Join-Path $Root 'PathMap.psd1'
        "@{ Paths = @(@{ BasePath = 'Catalog/Script.ps1'; NewPath = 'Catalog/Script.ps1' }) }" |
            Set-Content -LiteralPath $pathMap -Encoding ascii
        $symbolMap = Join-Path $Root 'SymbolMap.psd1'
        @"
@{
    Commands = @()
    Aliases = @()
    Functions = @(
        @{ Path = 'Catalog/Script.ps1'; OldName = 'IsMember'; NewName = 'Test-GroupMembership' }
    )
}
"@ | Set-Content -LiteralPath $symbolMap -Encoding ascii
        $reportPath = Join-Path $Root 'RewriteReport.json'

        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $tools 'Test-PowerShellRewrite.ps1') `
            -BaseRevision $baseRevision `
            -PathMap $pathMap `
            -SymbolMap $symbolMap `
            -ReportPath $reportPath
        $exitCode = $LASTEXITCODE

        return [pscustomobject]@{
            ExitCode = $exitCode
            Report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
        }
    }
}

Describe 'PowerShell rewrite equivalence' {
    It 'accepts trivia-only formatting with identical AST and semantic tokens' {
        $result = Compare-PowerShellSource -BeforePath "$fixtureRoot/Trivia.Before.ps1" -AfterPath "$fixtureRoot/Trivia.After.ps1"
        $result.Passed | Should -BeTrue
    }

    It 'fails closed for BOM-less non-ASCII source bytes' {
        $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false, $true)
        $contentBytes = $utf8WithoutBom.GetBytes("`$value = 'é'`n")
        $utf8WithBomBytes = [byte[]] (@(0xEF, 0xBB, 0xBF) + @($contentBytes))

        {
            Compare-PowerShellSource `
                -BeforePath 'Before.ps1' `
                -AfterPath 'After.ps1' `
                -BeforeBytes $contentBytes `
                -AfterBytes $utf8WithBomBytes
        } | Should -Throw '*BOM*'
    }

    It 'rejects a parser error on either side' {
        $result = Compare-PowerShellSource -BeforePath "$fixtureRoot/ParserError.Before.ps1" -AfterPath "$fixtureRoot/ParserError.After.ps1"
        $result.Passed | Should -BeFalse
        $result.Failures | Should -Contain 'After source contains parser errors.'

        $reverse = Compare-PowerShellSource -BeforePath "$fixtureRoot/ParserError.After.ps1" -AfterPath "$fixtureRoot/ParserError.Before.ps1"
        $reverse.Passed | Should -BeFalse
        $reverse.Failures | Should -Contain 'Before source contains parser errors.'
    }

    It 'accepts an alias only through an explicit canonical-command map' {
        $map = @{ Aliases = @(@{ OldName = '?'; NewName = 'Where-Object'; Occurrence = 1 }); Functions = @() }
        $result = Compare-PowerShellSource -BeforePath "$fixtureRoot/Alias.Before.ps1" -AfterPath "$fixtureRoot/Alias.After.ps1" -SymbolMap $map
        $result.Passed | Should -BeTrue

        (Compare-PowerShellSource -BeforePath "$fixtureRoot/Alias.Before.ps1" -AfterPath "$fixtureRoot/Alias.After.ps1").Passed |
            Should -BeFalse
    }

    It 'resolves alias metadata case-insensitively while matching source occurrences case-sensitively' {
        $before = Join-Path $TestDrive 'AliasCase.Before.ps1'
        $after = Join-Path $TestDrive 'AliasCase.After.ps1'
        @'
start 'https://example.invalid/lowercase'
Start 'https://example.invalid/source-exact'
'@ | Set-Content -LiteralPath $before -Encoding utf8
        @'
start 'https://example.invalid/lowercase'
Start-Process 'https://example.invalid/source-exact'
'@ | Set-Content -LiteralPath $after -Encoding utf8
        $startAliasMapping = @($foundationSymbolMap.Aliases |
                Where-Object Path -CEQ 'Run-Browser/Remediate-Run-Browser.ps1')[0]
        $map = @{
            Aliases = @($startAliasMapping)
            Functions = @()
        }

        $result = Compare-PowerShellSource -BeforePath $before -AfterPath $after -SymbolMap $map
        $result.Passed | Should -BeTrue -Because ($result.Failures -join "`n")
    }

    It 'accepts explicit canonical command casing only through its occurrence map' {
        $before = Join-Path $TestDrive 'Command.Before.ps1'
        $after = Join-Path $TestDrive 'Command.After.ps1'
        Set-Content -LiteralPath $before -Value 'get-process | out-null' -Encoding utf8
        Set-Content -LiteralPath $after -Value 'Get-Process | Out-Null' -Encoding utf8
        $map = @{
            Commands = @(
                @{ OldName = 'get-process'; NewName = 'Get-Process'; Occurrence = 1 }
                @{ OldName = 'out-null'; NewName = 'Out-Null'; Occurrence = 1 }
            )
            Aliases = @()
            Functions = @()
        }

        (Compare-PowerShellSource -BeforePath $before -AfterPath $after -SymbolMap $map).Passed |
            Should -BeTrue
    }

    It 'maps command casing after an unchanged dynamic invocation' {
        $before = Join-Path $TestDrive 'CommandAfterDynamic.Before.ps1'
        $after = Join-Path $TestDrive 'CommandAfterDynamic.After.ps1'
        Set-Content -LiteralPath $before -Value '& $tool; get-process' -Encoding utf8
        Set-Content -LiteralPath $after -Value '& $tool; Get-Process' -Encoding utf8
        $map = @{
            Commands = @(
                @{ OldName = 'get-process'; NewName = 'Get-Process'; Occurrence = 1 }
            )
            Aliases = @()
            Functions = @()
        }

        $result = Compare-PowerShellSource `
            -BeforePath $before `
            -AfterPath $after `
            -SymbolMap $map
        $result.Passed | Should -BeTrue -Because ($result.Failures -join "`n")
    }

    It 'does not auto-load a module to resolve a command mapping' {
        $moduleRoot = Join-Path $TestDrive 'Modules'
        $moduleDirectory = Join-Path $moduleRoot 'AutoLoadProbe'
        $marker = Join-Path $TestDrive 'module-loaded.txt'
        New-Item -ItemType Directory -Path $moduleDirectory -Force | Out-Null
        @"
Set-Content -LiteralPath '$marker' -Value 'loaded'
function Invoke-AutoLoadProbe {}
Export-ModuleMember -Function Invoke-AutoLoadProbe
"@ | Set-Content -LiteralPath (Join-Path $moduleDirectory 'AutoLoadProbe.psm1') -Encoding utf8
        @'
@{
    RootModule = 'AutoLoadProbe.psm1'
    ModuleVersion = '1.0.0'
    GUID = '8d16650f-34fe-45dc-9d77-8ed8fde0506e'
    FunctionsToExport = @('Invoke-AutoLoadProbe')
}
'@ | Set-Content -LiteralPath (Join-Path $moduleDirectory 'AutoLoadProbe.psd1') -Encoding ascii

        $before = Join-Path $TestDrive 'AutoLoad.Before.ps1'
        $after = Join-Path $TestDrive 'AutoLoad.After.ps1'
        Set-Content -LiteralPath $before -Value 'invoke-autoloadprobe' -Encoding utf8
        Set-Content -LiteralPath $after -Value 'Invoke-AutoLoadProbe' -Encoding utf8
        $map = @{
            Commands = @(@{ OldName = 'invoke-autoloadprobe'; NewName = 'Invoke-AutoLoadProbe'; Occurrence = 1 })
            Aliases = @()
            Functions = @()
        }

        $originalModulePath = $env:PSModulePath
        try {
            $env:PSModulePath = $moduleRoot + [System.IO.Path]::PathSeparator + $originalModulePath
            $result = Compare-PowerShellSource -BeforePath $before -AfterPath $after -SymbolMap $map
            $result.Passed | Should -BeFalse
            Test-Path -LiteralPath $marker | Should -BeFalse
        }
        finally {
            $env:PSModulePath = $originalModulePath
            Remove-Module AutoLoadProbe -Force -ErrorAction SilentlyContinue
        }
    }

    It 'accepts a function rename only when definition and all static callsites map' {
        $map = @{ Aliases = @(); Functions = @(@{ OldName = 'IsMember'; NewName = 'Test-GroupMembership' }) }
        $result = Compare-PowerShellSource -BeforePath "$fixtureRoot/Function.Before.ps1" -AfterPath "$fixtureRoot/Function.After.ps1" -SymbolMap $map
        $result.Passed | Should -BeTrue
    }

    It 'accepts a function rename in a scope-qualified static call' {
        $before = Join-Path $TestDrive 'FunctionQualified.Before.ps1'
        $after = Join-Path $TestDrive 'FunctionQualified.After.ps1'
        @'
function IsMember {}
global:IsMember
'@ | Set-Content -LiteralPath $before -Encoding utf8
        @'
function Test-GroupMembership {}
global:Test-GroupMembership
'@ | Set-Content -LiteralPath $after -Encoding utf8
        $map = @{ Aliases = @(); Functions = @(@{ OldName = 'IsMember'; NewName = 'Test-GroupMembership' }) }

        $result = Compare-PowerShellSource -BeforePath $before -AfterPath $after -SymbolMap $map
        $result.Passed | Should -BeTrue -Because ($result.Failures -join "`n")
    }

    It 'rejects an unresolved old function in a scope-qualified static call' {
        $before = Join-Path $TestDrive 'FunctionQualifiedUnresolved.Before.ps1'
        $after = Join-Path $TestDrive 'FunctionQualifiedUnresolved.After.ps1'
        @'
function IsMember {}
global:IsMember
'@ | Set-Content -LiteralPath $before -Encoding utf8
        @'
function Test-GroupMembership {}
global:Test-GroupMembership
global:IsMember
'@ | Set-Content -LiteralPath $after -Encoding utf8
        $map = @{ Aliases = @(); Functions = @(@{ OldName = 'IsMember'; NewName = 'Test-GroupMembership' }) }

        $result = Compare-PowerShellSource -BeforePath $before -AfterPath $after -SymbolMap $map
        $result.Passed | Should -BeFalse
        $result.Failures -join "`n" | Should -Match 'unresolved old function symbol'
    }

    It 'ignores a variable whose name case-insensitively matches the renamed function' {
        $source = Join-Path $repositoryRoot 'Enable-RDP/Detect-Enable-RDP.ps1'
        $before = Join-Path $TestDrive 'FunctionVariable.Before.ps1'
        $after = Join-Path $TestDrive 'FunctionVariable.After.ps1'
        $afterText = [System.IO.File]::ReadAllText($source)
        $beforeText = $afterText.Replace('Test-GroupMembership', 'IsMember')
        $beforeText | Set-Content -LiteralPath $before -Encoding utf8
        $afterText | Set-Content -LiteralPath $after -Encoding utf8
        $functionMapping = @($foundationSymbolMap.Functions |
                Where-Object Path -CEQ 'Enable-RDP/Detect-Enable-RDP.ps1')[0]
        $map = @{ Aliases = @(); Functions = @($functionMapping) }

        $result = Compare-PowerShellSource -BeforePath $before -AfterPath $after -SymbolMap $map
        $result.Passed | Should -BeTrue -Because ($result.Failures -join "`n")
    }

    It 'rejects an unresolved old function call' {
        $after = Join-Path $TestDrive 'Function.UnresolvedCall.ps1'
        @'
function Test-GroupMembership {
    param([string] $Group)

    return $Group -eq 'Administrators'
}

Test-GroupMembership -Group 'Administrators'
IsMember -Group 'Administrators'
'@ | Set-Content -LiteralPath $after -Encoding utf8
        $map = @{ Aliases = @(); Functions = @(@{ OldName = 'IsMember'; NewName = 'Test-GroupMembership' }) }

        $result = Compare-PowerShellSource -BeforePath "$fixtureRoot/Function.Before.ps1" -AfterPath $after -SymbolMap $map
        $result.Passed | Should -BeFalse
        $result.Failures -join "`n" | Should -Match 'unresolved old function symbol'
    }

    It 'rejects an unresolved old function definition' {
        $after = Join-Path $TestDrive 'Function.UnresolvedDefinition.ps1'
        @'
function Test-GroupMembership {
    param([string] $Group)

    return $Group -eq 'Administrators'
}
function IsMember {
    param([string] $Group)

    return $Group -eq 'Administrators'
}

Test-GroupMembership -Group 'Administrators'
'@ | Set-Content -LiteralPath $after -Encoding utf8
        $map = @{ Aliases = @(); Functions = @(@{ OldName = 'IsMember'; NewName = 'Test-GroupMembership' }) }

        $result = Compare-PowerShellSource -BeforePath "$fixtureRoot/Function.Before.ps1" -AfterPath $after -SymbolMap $map
        $result.Passed | Should -BeFalse
        $result.Failures -join "`n" | Should -Match 'unresolved old function symbol'
    }

    It 'rejects an unresolved old function used as a dynamic invocation target' {
        $after = Join-Path $TestDrive 'Function.UnresolvedDynamicCall.ps1'
        @'
function Test-GroupMembership {
    param([string] $Group)

    return $Group -eq 'Administrators'
}
Test-GroupMembership -Group 'Administrators'
& $IsMember -Group 'Administrators'
'@ | Set-Content -LiteralPath $after -Encoding utf8
        $map = @{ Aliases = @(); Functions = @(@{ OldName = 'IsMember'; NewName = 'Test-GroupMembership' }) }

        $result = Compare-PowerShellSource -BeforePath "$fixtureRoot/Function.Before.ps1" -AfterPath $after -SymbolMap $map
        $result.Passed | Should -BeFalse
        $result.Failures -join "`n" | Should -Match 'unresolved old function symbol'
    }

    It 'rejects a changed backtick continuation neighbor' {
        (Compare-PowerShellSource -BeforePath "$fixtureRoot/Backtick.Before.ps1" -AfterPath "$fixtureRoot/Backtick.After.ps1").Passed | Should -BeFalse
    }

    It 'rejects movement of a pipeline-adjacent comment' {
        (Compare-PowerShellSource -BeforePath "$fixtureRoot/Comment.Before.ps1" -AfterPath "$fixtureRoot/Comment.After.ps1").Passed | Should -BeFalse
    }

    It 'rejects changed help association even when help text is unchanged' {
        $before = Join-Path $TestDrive 'Help.Before.ps1'
        $after = Join-Path $TestDrive 'Help.After.ps1'
        @'
<#
.SYNOPSIS
Gets a value.
.PARAMETER Name
The name.
#>
function Get-FirstValue { param([string] $Name) $Name }
function Get-SecondValue { param([string] $Name) $Name }
'@ | Set-Content -LiteralPath $before -Encoding utf8
        @'
function Get-FirstValue { param([string] $Name) $Name }
<#
.SYNOPSIS
Gets a value.
.PARAMETER Name
The name.
#>
function Get-SecondValue { param([string] $Name) $Name }
'@ | Set-Content -LiteralPath $after -Encoding utf8

        (Compare-PowerShellSource -BeforePath $before -AfterPath $after).Passed | Should -BeFalse
    }

    It 'rejects a changed here-string value' {
        (Compare-PowerShellSource -BeforePath "$fixtureRoot/HereString.Before.ps1" -AfterPath "$fixtureRoot/HereString.After.ps1").Passed | Should -BeFalse
    }

    It 'rejects a line-ending change inside a here-string value' {
        $before = Join-Path $TestDrive 'HereStringLineEnding.Before.ps1'
        $after = Join-Path $TestDrive 'HereStringLineEnding.After.ps1'
        $beforeText = '$message = @"' + "`r`n" + 'same value' + "`r`n" + '"@' + "`r`n"
        $afterText = '$message = @"' + "`n" + 'same value' + "`n" + '"@' + "`n"
        $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($before, $beforeText, $utf8WithoutBom)
        [System.IO.File]::WriteAllText($after, $afterText, $utf8WithoutBom)

        (Compare-PowerShellSource -BeforePath $before -AfterPath $after).Passed | Should -BeFalse
    }

    It 'rejects a changed dynamic invocation target' {
        (Compare-PowerShellSource -BeforePath "$fixtureRoot/Dynamic.Before.ps1" -AfterPath "$fixtureRoot/Dynamic.After.ps1").Passed | Should -BeFalse
    }

    It 'rejects a path map that is not a total bijection' {
        $rows = @(
            @{ BasePath = 'A.ps1'; NewPath = 'One.ps1' }
            @{ BasePath = 'B.ps1'; NewPath = 'One.ps1' }
        )
        Test-PathMapBijection -Rows $rows -ExpectedCount 2 | Should -BeFalse
        Test-PathMapBijection -Rows @(@{ BasePath = '../A.ps1'; NewPath = 'One.ps1' }) -ExpectedCount 1 | Should -BeFalse
        Test-PathMapBijection -Rows @(@{ BasePath = 'A.ps1'; NewPath = '/absolute.ps1' }) -ExpectedCount 1 | Should -BeFalse
        Test-PathMapBijection -Rows @(@{ BasePath = 'A.ps1'; NewPath = 'One.ps1' }) -ExpectedCount 2 | Should -BeFalse
    }
}

Describe 'PowerShell rewrite wrapper' {
    AfterEach {
        Remove-Item Env:REWRITE_EXECUTION_MARKER -ErrorAction SilentlyContinue
    }

    It 'reports an old function name stored in a string used by indirect dynamic invocation' {
        $result = Invoke-CatalogFunctionReferenceGate `
            -Root (Join-Path $TestDrive 'indirect-dynamic-reference') `
            -CandidateSource '$target = ''IsMember''; & $target'

        $result.ExitCode | Should -Be 1
        $result.Report.Passed | Should -BeFalse
        @($result.Report.Failures) | Should -Be @(
            "Catalog file 'Catalog/Script.ps1' contains unresolved old function symbol 'IsMember'."
        )
    }

    It 'reports an escaped old function name in an expandable dynamic target string' {
        $result = Invoke-CatalogFunctionReferenceGate `
            -Root (Join-Path $TestDrive 'escaped-expandable-reference') `
            -CandidateSource '$target = "Is`Member$empty"; & $target'

        $result.ExitCode | Should -Be 1
        $result.Report.Passed | Should -BeFalse
        @($result.Report.Failures) | Should -Be @(
            "Catalog file 'Catalog/Script.ps1' contains unresolved old function symbol 'IsMember'."
        )
    }

    It 'reports a bare old function string expression' {
        $result = Invoke-CatalogFunctionReferenceGate `
            -Root (Join-Path $TestDrive 'bare-string-reference') `
            -CandidateSource "'IsMember'"

        $result.ExitCode | Should -Be 1
        $result.Report.Passed | Should -BeFalse
        @($result.Report.Failures) | Should -Be @(
            "Catalog file 'Catalog/Script.ps1' contains unresolved old function symbol 'IsMember'."
        )
    }

    It 'does not report an ordinary variable named after the old function' {
        $result = Invoke-CatalogFunctionReferenceGate `
            -Root (Join-Path $TestDrive 'ordinary-variable') `
            -CandidateSource '$isMember = $false'

        $result.ExitCode | Should -Be 0
        $result.Report.Passed | Should -BeTrue
        @($result.Report.Failures).Count | Should -Be 0
    }

    It 'does not report a member identifier named after the old function' {
        $result = Invoke-CatalogFunctionReferenceGate `
            -Root (Join-Path $TestDrive 'member-identifier') `
            -CandidateSource '$result.IsMember'

        $result.ExitCode | Should -Be 0
        $result.Report.Passed | Should -BeTrue
        @($result.Report.Failures).Count | Should -Be 0
    }

    It 'validates a two-file Git rewrite, writes sorted JSON, and never executes source' {
        $repo = Join-Path $TestDrive 'repo'
        $tools = Join-Path $repo 'tools'
        $catalog = Join-Path $repo 'Catalog'
        $renamed = Join-Path $repo 'Renamed'
        New-Item -ItemType Directory -Path $tools, $catalog -Force | Out-Null
        Copy-Item -LiteralPath "$PSScriptRoot/../tools/RewriteEquivalence.psm1" -Destination $tools
        Copy-Item -LiteralPath $wrapperPath -Destination $tools
        Copy-Item -LiteralPath "$PSScriptRoot/../build.ps1" -Destination $repo

        $marker = Join-Path $repo 'executed.txt'
        $env:REWRITE_EXECUTION_MARKER = $marker
        "Set-Content -LiteralPath `$env:REWRITE_EXECUTION_MARKER -Value 'Zeta executed'" |
            Set-Content -LiteralPath (Join-Path $catalog 'Zeta.ps1') -Encoding utf8
        "Set-Content -LiteralPath `$env:REWRITE_EXECUTION_MARKER -Value 'Alpha executed'" |
            Set-Content -LiteralPath (Join-Path $catalog 'Alpha.ps1') -Encoding utf8

        & git -C $repo init --quiet
        & git -C $repo config core.autocrlf false
        & git -C $repo config user.email 'rewrite-gate@example.invalid'
        & git -C $repo config user.name 'Rewrite Gate Test'
        & git -C $repo add Catalog
        & git -C $repo commit --quiet -m baseline
        $baseRevision = (& git -C $repo rev-parse HEAD).Trim()

        Remove-Item -LiteralPath $catalog -Recurse -Force
        New-Item -ItemType Directory -Path $renamed -Force | Out-Null
        "Set-Content -LiteralPath `$env:REWRITE_EXECUTION_MARKER -Value 'Zeta executed'" |
            Set-Content -LiteralPath (Join-Path $renamed 'Zeta.ps1') -Encoding utf8
        "Set-Content -LiteralPath `$env:REWRITE_EXECUTION_MARKER -Value 'Alpha executed'" |
            Set-Content -LiteralPath (Join-Path $renamed 'Alpha.ps1') -Encoding utf8

        $pathMap = Join-Path $repo 'PathMap.psd1'
        @"
@{
    Paths = @(
        @{ BasePath = 'Catalog/Zeta.ps1'; NewPath = 'Renamed/Zeta.ps1' }
        @{ BasePath = 'Catalog/Alpha.ps1'; NewPath = 'Renamed/Alpha.ps1' }
    )
}
"@ | Set-Content -LiteralPath $pathMap -Encoding ascii
        $symbolMap = Join-Path $repo 'SymbolMap.psd1'
        '@{ Commands = @(); Aliases = @(); Functions = @() }' |
            Set-Content -LiteralPath $symbolMap -Encoding ascii
        $reportPath = Join-Path $repo 'RewriteReport.json'

        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'build.ps1') `
            -Task ValidateRewrite `
            -BaseRevision $baseRevision `
            -PathMap $pathMap `
            -SymbolMap $symbolMap `
            -ReportPath $reportPath
        $LASTEXITCODE | Should -Be 0
        Test-Path -LiteralPath $marker | Should -BeFalse

        $report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
        $report.BaseRevision | Should -Be $baseRevision
        $report.Passed | Should -BeTrue
        @($report.Rows).Count | Should -Be 2
        @($report.Rows.NewPath) | Should -Be @('Renamed/Alpha.ps1', 'Renamed/Zeta.ps1')
        @($report.Rows.Passed | Where-Object { -not $_ }).Count | Should -Be 0

        @"
@{
    Commands = @()
    Aliases = @(
        @{ Path = 'Renamed/Missing.ps1'; OldName = '?'; NewName = 'Where-Object'; Occurrence = 1 }
    )
    Functions = @()
}
"@ | Set-Content -LiteralPath $symbolMap -Encoding ascii
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'build.ps1') `
            -Task ValidateRewrite `
            -BaseRevision $baseRevision `
            -PathMap $pathMap `
            -SymbolMap $symbolMap `
            -ReportPath $reportPath
        $LASTEXITCODE | Should -Be 1
        $unmatchedReport = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
        $unmatchedReport.Passed | Should -BeFalse
        $unmatchedReport.Failures -join "`n" | Should -Match 'symbol map'
    }

    It 'compares an empty base Git blob instead of falling back to the working tree' {
        $repo = Join-Path $TestDrive 'empty-repo'
        $tools = Join-Path $repo 'tools'
        $catalog = Join-Path $repo 'Catalog'
        New-Item -ItemType Directory -Path $tools, $catalog -Force | Out-Null
        Copy-Item -LiteralPath "$PSScriptRoot/../tools/RewriteEquivalence.psm1" -Destination $tools
        Copy-Item -LiteralPath $wrapperPath -Destination $tools
        Copy-Item -LiteralPath "$PSScriptRoot/../build.ps1" -Destination $repo

        $emptyPath = Join-Path $catalog 'Empty.ps1'
        [System.IO.File]::WriteAllText($emptyPath, '', (New-Object System.Text.UTF8Encoding($false)))
        & git -C $repo init --quiet
        & git -C $repo config core.autocrlf false
        & git -C $repo config user.email 'rewrite-gate@example.invalid'
        & git -C $repo config user.name 'Rewrite Gate Test'
        & git -C $repo add Catalog
        & git -C $repo commit --quiet -m baseline
        $baseRevision = (& git -C $repo rev-parse HEAD).Trim()
        Set-Content -LiteralPath $emptyPath -Value "Write-Output 'changed'" -Encoding ascii

        $pathMap = Join-Path $repo 'PathMap.psd1'
        "@{ Paths = @(@{ BasePath = 'Catalog/Empty.ps1'; NewPath = 'Catalog/Empty.ps1' }) }" |
            Set-Content -LiteralPath $pathMap -Encoding ascii
        $symbolMap = Join-Path $repo 'SymbolMap.psd1'
        '@{ Commands = @(); Aliases = @(); Functions = @() }' |
            Set-Content -LiteralPath $symbolMap -Encoding ascii
        $reportPath = Join-Path $repo 'RewriteReport.json'

        Push-Location $repo
        try {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'build.ps1') `
                -Task ValidateRewrite `
                -BaseRevision $baseRevision `
                -PathMap $pathMap `
                -SymbolMap $symbolMap `
                -ReportPath $reportPath
            $exitCode = $LASTEXITCODE
        }
        finally {
            Pop-Location
        }

        $exitCode | Should -Be 1
        (Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json).Passed | Should -BeFalse
    }

    It 'orders multiple unresolved catalog reference failures by ordinal repository path' {
        $repo = Join-Path $TestDrive 'unresolved-repo'
        $tools = Join-Path $repo 'tools'
        $catalog = Join-Path $repo 'Catalog'
        New-Item -ItemType Directory -Path $tools, $catalog -Force | Out-Null
        Copy-Item -LiteralPath "$PSScriptRoot/../tools/RewriteEquivalence.psm1" -Destination $tools
        Copy-Item -LiteralPath $wrapperPath -Destination $tools
        Copy-Item -LiteralPath "$PSScriptRoot/../build.ps1" -Destination $repo

        @'
function IsMember {
    param([string] $Group)
    $isMember = $false
    return $Group -eq 'Administrators'
}
IsMember -Group 'Administrators'
'@ | Set-Content -LiteralPath (Join-Path $catalog 'A.ps1') -Encoding utf8
        "`$reference = 'IsMember'" | Set-Content -LiteralPath (Join-Path $catalog 'Zeta.md') -Encoding utf8
        "`$reference = 'IsMember'" | Set-Content -LiteralPath (Join-Path $catalog 'alpha.psd1') -Encoding utf8
        'IsMember' | Set-Content -LiteralPath (Join-Path $catalog 'B.ps1') -Encoding utf8
        'function IsMember {}' | Set-Content -LiteralPath (Join-Path $catalog 'C.ps1') -Encoding utf8
        'global:IsMember' | Set-Content -LiteralPath (Join-Path $catalog 'D.ps1') -Encoding utf8
        & git -C $repo init --quiet
        & git -C $repo config core.autocrlf false
        & git -C $repo config user.email 'rewrite-gate@example.invalid'
        & git -C $repo config user.name 'Rewrite Gate Test'
        & git -C $repo add Catalog
        & git -C $repo commit --quiet -m baseline
        $baseRevision = (& git -C $repo rev-parse HEAD).Trim()

        @'
function Test-GroupMembership {
    param([string] $Group)
    $isMember = $false
    return $Group -eq 'Administrators'
}
Test-GroupMembership -Group 'Administrators'
'@ | Set-Content -LiteralPath (Join-Path $catalog 'A.ps1') -Encoding utf8
        $pathMap = Join-Path $repo 'PathMap.psd1'
        @"
@{
    Paths = @(
        @{ BasePath = 'Catalog/A.ps1'; NewPath = 'Catalog/A.ps1' }
        @{ BasePath = 'Catalog/B.ps1'; NewPath = 'Catalog/B.ps1' }
        @{ BasePath = 'Catalog/C.ps1'; NewPath = 'Catalog/C.ps1' }
        @{ BasePath = 'Catalog/D.ps1'; NewPath = 'Catalog/D.ps1' }
    )
}
"@ | Set-Content -LiteralPath $pathMap -Encoding ascii
        $symbolMap = Join-Path $repo 'SymbolMap.psd1'
        @"
@{
    Commands = @()
    Aliases = @()
    Functions = @(
        @{ Path = 'Catalog/A.ps1'; OldName = 'IsMember'; NewName = 'Test-GroupMembership' }
    )
}
"@ | Set-Content -LiteralPath $symbolMap -Encoding ascii
        $reportPath = Join-Path $repo 'RewriteReport.json'

        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'build.ps1') `
            -Task ValidateRewrite `
            -BaseRevision $baseRevision `
            -PathMap $pathMap `
            -SymbolMap $symbolMap `
            -ReportPath $reportPath
        $LASTEXITCODE | Should -Be 1
        $report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
        $report.Passed | Should -BeFalse
        @($report.Failures) | Should -Be @(
            "Catalog file 'Catalog/B.ps1' contains unresolved old function symbol 'IsMember'."
            "Catalog file 'Catalog/C.ps1' contains unresolved old function symbol 'IsMember'."
            "Catalog file 'Catalog/D.ps1' contains unresolved old function symbol 'IsMember'."
            "Catalog file 'Catalog/Zeta.md' contains unresolved old function symbol 'IsMember'."
            "Catalog file 'Catalog/alpha.psd1' contains unresolved old function symbol 'IsMember'."
        )
    }
}
