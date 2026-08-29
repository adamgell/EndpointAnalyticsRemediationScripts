Set-StrictMode -Version Latest

function Get-PropertyValue {
    param(
        [Parameter(Mandatory)] $InputObject,
        [Parameter(Mandatory)] [string] $Name
    )

    if ($InputObject -is [System.Collections.IDictionary] -and $InputObject.Contains($Name)) {
        return $InputObject[$Name]
    }

    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -ne $property) {
        return $property.Value
    }

    return $null
}

function Get-MapRows {
    param(
        $SymbolMap,
        [Parameter(Mandatory)] [string] $Name
    )

    if ($null -eq $SymbolMap) {
        return @()
    }

    $value = Get-PropertyValue -InputObject $SymbolMap -Name $Name
    if ($null -eq $value) {
        return @()
    }
    return @($value)
}

function ConvertTo-NormalizedNewline {
    param([AllowEmptyString()] [string] $Value)

    if ($null -eq $Value) {
        return ''
    }

    return $Value.Replace("`r`n", "`n").Replace("`r", "`n")
}

function Get-Sha256Hex {
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [byte[]] $Bytes)

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([System.BitConverter]::ToString($sha256.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha256.Dispose()
    }
}

function Get-TextFingerprint {
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [string[]] $Entries)

    $joined = [string]::Join("`n", $Entries)
    return Get-Sha256Hex -Bytes ([System.Text.Encoding]::UTF8.GetBytes($joined))
}

function ConvertFrom-ScriptBytes {
    [CmdletBinding()]
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [byte[]] $Bytes)

    $encoding = $null
    $offset = 0

    if ($Bytes.Length -ge 4 -and
        $Bytes[0] -eq 0x00 -and $Bytes[1] -eq 0x00 -and
        $Bytes[2] -eq 0xFE -and $Bytes[3] -eq 0xFF) {
        $encoding = New-Object System.Text.UTF32Encoding($true, $true, $true)
        $offset = 4
    }
    elseif ($Bytes.Length -ge 4 -and
        $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE -and
        $Bytes[2] -eq 0x00 -and $Bytes[3] -eq 0x00) {
        $encoding = New-Object System.Text.UTF32Encoding($false, $true, $true)
        $offset = 4
    }
    elseif ($Bytes.Length -ge 3 -and
        $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        $encoding = New-Object System.Text.UTF8Encoding($false, $true)
        $offset = 3
    }
    elseif ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFE -and $Bytes[1] -eq 0xFF) {
        $encoding = New-Object System.Text.UnicodeEncoding($true, $true, $true)
        $offset = 2
    }
    elseif ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE) {
        $encoding = New-Object System.Text.UnicodeEncoding($false, $true, $true)
        $offset = 2
    }
    else {
        foreach ($byte in $Bytes) {
            if ($byte -ge 0x80) {
                throw 'BOM-less non-ASCII source cannot be decoded deterministically under Windows PowerShell 5.1.'
            }
        }
        $encoding = New-Object System.Text.UTF8Encoding($false, $true)
    }

    return $encoding.GetString($Bytes, $offset, $Bytes.Length - $offset)
}

function Get-ParsedScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Path,
        [byte[]] $Bytes
    )

    if ($null -eq $Bytes) {
        $Bytes = [System.IO.File]::ReadAllBytes($Path)
    }

    $text = ConvertFrom-ScriptBytes -Bytes $Bytes
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput(
        $text,
        $Path,
        [ref] $tokens,
        [ref] $errors
    )

    return [pscustomobject][ordered]@{
        Path = $Path
        Bytes = $Bytes
        ByteHash = Get-Sha256Hex -Bytes $Bytes
        Text = $text
        Ast = $ast
        Tokens = @($tokens)
        Errors = @($errors)
    }
}

function Get-AstShapeFingerprint {
    [CmdletBinding()]
    param([Parameter(Mandatory)] $ParsedScript)

    $nodes = @($ParsedScript.Ast.FindAll({ param($node) $true }, $true))
    $indices = @{}
    for ($index = 0; $index -lt $nodes.Count; $index++) {
        $indices[$nodes[$index]] = $index
    }

    $nextChildOrder = @{}
    $entries = New-Object 'System.Collections.Generic.List[string]'
    for ($index = 0; $index -lt $nodes.Count; $index++) {
        $node = $nodes[$index]
        if ($null -eq $node.Parent) {
            $parentIndex = -1
            $childOrder = 0
        }
        else {
            $parentIndex = [int] $indices[$node.Parent]
            $parentKey = [string] $parentIndex
            if (-not $nextChildOrder.ContainsKey($parentKey)) {
                $nextChildOrder[$parentKey] = 0
            }
            $childOrder = [int] $nextChildOrder[$parentKey]
            $nextChildOrder[$parentKey] = $childOrder + 1
        }

        $entries.Add(('{0}|{1}|{2}' -f $node.GetType().FullName, $parentIndex, $childOrder))
    }

    $entryArray = $entries.ToArray()
    return [pscustomobject][ordered]@{
        Hash = Get-TextFingerprint -Entries $entryArray
        Count = $entryArray.Count
        Entries = $entryArray
    }
}

function Get-TokenValue {
    param([Parameter(Mandatory)] $Token)

    if ($Token -is [System.Management.Automation.Language.VariableToken]) {
        return [string] $Token.VariablePath.UserPath
    }

    $valueProperty = $Token.PSObject.Properties['Value']
    if ($null -ne $valueProperty -and $null -ne $valueProperty.Value) {
        return [string] $Token.Text
    }

    if ($Token.Kind -eq [System.Management.Automation.Language.TokenKind]::LineContinuation) {
        return ConvertTo-NormalizedNewline -Value ([string] $Token.Text)
    }
    return [string] $Token.Text
}

function Test-IsSemanticToken {
    param([Parameter(Mandatory)] $Token)

    return $Token.Kind -notin @(
        [System.Management.Automation.Language.TokenKind]::Comment,
        [System.Management.Automation.Language.TokenKind]::NewLine,
        [System.Management.Automation.Language.TokenKind]::EndOfInput
    )
}

function Get-TokenIdentity {
    param(
        [Parameter(Mandatory)] $Token,
        [hashtable] $Normalizations
    )

    $offsetKey = [string] $Token.Extent.StartOffset
    if ($null -ne $Normalizations -and $Normalizations.ContainsKey($offsetKey)) {
        $normalization = $Normalizations[$offsetKey]
        $normalizedKind = Get-PropertyValue -InputObject $normalization -Name 'Kind'
        if ($null -ne $normalizedKind) {
            return '{0}|{1}|{2}' -f
                $normalizedKind,
                (Get-PropertyValue -InputObject $normalization -Name 'Flags'),
                (Get-PropertyValue -InputObject $normalization -Name 'Value')
        }
        $value = [string] $normalization
    }
    else {
        $value = Get-TokenValue -Token $Token
    }

    return '{0}|{1}|{2}' -f $Token.Kind, $Token.TokenFlags, $value
}

function Get-SemanticTokenFingerprint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $ParsedScript,
        [hashtable] $Normalizations,
        [int] $StartOffset = -1,
        [int] $EndOffset = -1
    )

    $entries = New-Object 'System.Collections.Generic.List[string]'
    foreach ($token in $ParsedScript.Tokens) {
        if (-not (Test-IsSemanticToken -Token $token)) {
            continue
        }
        if ($StartOffset -ge 0 -and $token.Extent.StartOffset -lt $StartOffset) {
            continue
        }
        if ($EndOffset -ge 0 -and $token.Extent.EndOffset -gt $EndOffset) {
            continue
        }

        $entries.Add((Get-TokenIdentity -Token $token -Normalizations $Normalizations))
    }

    $entryArray = $entries.ToArray()
    return [pscustomobject][ordered]@{
        Hash = Get-TextFingerprint -Entries $entryArray
        Count = $entryArray.Count
        Entries = $entryArray
    }
}

function Get-NormalizedCommentText {
    param([Parameter(Mandatory)] [string] $Text)

    $lines = (ConvertTo-NormalizedNewline -Value $Text).Split("`n")
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $lines[$index] = $lines[$index].TrimEnd()
    }
    return [string]::Join("`n", $lines)
}

function Get-HelpKeywordStructure {
    param([Parameter(Mandatory)] $HelpContent)

    $entries = New-Object 'System.Collections.Generic.List[string]'
    foreach ($propertyName in @(
        'Synopsis', 'Description', 'Notes', 'Component', 'Role', 'Functionality',
        'ForwardHelpTargetName', 'ForwardHelpCategory', 'RemoteHelpRunspace',
        'MamlHelpFile', 'ExternalHelpFile'
    )) {
        $property = $HelpContent.PSObject.Properties[$propertyName]
        if ($null -ne $property -and $null -ne $property.Value -and
            -not [string]::IsNullOrWhiteSpace([string] $property.Value)) {
            $entries.Add($propertyName.ToUpperInvariant())
        }
    }

    $parametersProperty = $HelpContent.PSObject.Properties['Parameters']
    if ($null -ne $parametersProperty -and $null -ne $parametersProperty.Value) {
        foreach ($parameterName in @($parametersProperty.Value.Keys)) {
            $entries.Add(('PARAMETER:{0}' -f $parameterName))
        }
    }

    $examplesProperty = $HelpContent.PSObject.Properties['Examples']
    if ($null -ne $examplesProperty -and $null -ne $examplesProperty.Value) {
        for ($index = 0; $index -lt @($examplesProperty.Value).Count; $index++) {
            $entries.Add('EXAMPLE')
        }
    }

    $linksProperty = $HelpContent.PSObject.Properties['Links']
    if ($null -ne $linksProperty -and $null -ne $linksProperty.Value) {
        for ($index = 0; $index -lt @($linksProperty.Value).Count; $index++) {
            $entries.Add('LINK')
        }
    }

    return $entries.ToArray()
}

function Get-CommentAnchorFingerprint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $ParsedScript,
        [hashtable] $Normalizations,
        [hashtable] $FunctionNames
    )

    $tokens = @($ParsedScript.Tokens)
    $entries = New-Object 'System.Collections.Generic.List[string]'
    for ($index = 0; $index -lt $tokens.Count; $index++) {
        $token = $tokens[$index]
        if ($token.Kind -ne [System.Management.Automation.Language.TokenKind]::Comment) {
            continue
        }

        $previous = '<START>'
        for ($previousIndex = $index - 1; $previousIndex -ge 0; $previousIndex--) {
            if (Test-IsSemanticToken -Token $tokens[$previousIndex]) {
                $previous = Get-TokenIdentity -Token $tokens[$previousIndex] -Normalizations $Normalizations
                break
            }
        }

        $next = '<END>'
        for ($nextIndex = $index + 1; $nextIndex -lt $tokens.Count; $nextIndex++) {
            if (Test-IsSemanticToken -Token $tokens[$nextIndex]) {
                $next = Get-TokenIdentity -Token $tokens[$nextIndex] -Normalizations $Normalizations
                break
            }
        }

        $entries.Add(('{0}|PREV={1}|NEXT={2}' -f (Get-NormalizedCommentText -Text $token.Text), $previous, $next))
    }

    $helpEntries = New-Object 'System.Collections.Generic.List[string]'
    $helpOwners = @([pscustomobject]@{ Name = '<SCRIPT>'; Ast = $ParsedScript.Ast })
    $functions = @($ParsedScript.Ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
    }, $true))
    foreach ($function in $functions) {
        $name = [string] $function.Name
        if ($null -ne $FunctionNames -and $FunctionNames.ContainsKey($name.ToLowerInvariant())) {
            $name = [string] $FunctionNames[$name.ToLowerInvariant()]
        }
        $helpOwners += [pscustomobject]@{ Name = "FUNCTION:$name"; Ast = $function }
    }

    foreach ($owner in $helpOwners) {
        $help = $owner.Ast.GetHelpContent()
        if ($null -eq $help) {
            continue
        }
        $keywords = @(Get-HelpKeywordStructure -HelpContent $help)
        $helpEntries.Add(('{0}|{1}' -f $owner.Name, ([string]::Join(',', $keywords))))
    }

    $entryArray = $entries.ToArray()
    $helpArray = $helpEntries.ToArray()
    $combined = @($entryArray + ($helpArray | ForEach-Object { "HELP|$_" }))
    return [pscustomobject][ordered]@{
        Hash = Get-TextFingerprint -Entries $combined
        Count = $entryArray.Count
        HelpCount = $helpArray.Count
        Entries = $entryArray
        HelpAssociations = $helpArray
    }
}

function Get-HereStringFingerprint {
    [CmdletBinding()]
    param([Parameter(Mandatory)] $ParsedScript)

    $entries = New-Object 'System.Collections.Generic.List[string]'
    foreach ($token in $ParsedScript.Tokens) {
        if ($token.Kind -notin @(
            [System.Management.Automation.Language.TokenKind]::HereStringExpandable,
            [System.Management.Automation.Language.TokenKind]::HereStringLiteral
        )) {
            continue
        }

        $text = ConvertTo-NormalizedNewline -Value ([string] $token.Text)
        $value = Get-TokenValue -Token $token
        $opener = if ($text.Length -ge 2) { $text.Substring(0, 2) } else { $text }
        $terminator = if ($text.Length -ge 2) { $text.Substring($text.Length - 2, 2) } else { $text }
        $terminatorCount = 0
        foreach ($line in $text.Split("`n")) {
            if ($line -eq '"@' -or $line -eq "'@") {
                $terminatorCount++
            }
        }
        $mode = if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::HereStringExpandable) {
            'Expandable'
        }
        else {
            'Literal'
        }
        $entries.Add(('{0}|{1}|{2}|{3}|{4}|{5}' -f $token.Kind, $mode, $value, $opener, $terminator, $terminatorCount))
    }

    $entryArray = $entries.ToArray()
    return [pscustomobject][ordered]@{
        Hash = Get-TextFingerprint -Entries $entryArray
        Count = $entryArray.Count
        Entries = $entryArray
    }
}

function Get-LineContinuationFingerprint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $ParsedScript,
        [hashtable] $Normalizations
    )

    $tokens = @($ParsedScript.Tokens)
    $entries = New-Object 'System.Collections.Generic.List[string]'
    for ($index = 0; $index -lt $tokens.Count; $index++) {
        if ($tokens[$index].Kind -ne [System.Management.Automation.Language.TokenKind]::LineContinuation) {
            continue
        }

        $previous = '<START>'
        for ($previousIndex = $index - 1; $previousIndex -ge 0; $previousIndex--) {
            if ((Test-IsSemanticToken -Token $tokens[$previousIndex]) -and
                $tokens[$previousIndex].Kind -ne [System.Management.Automation.Language.TokenKind]::LineContinuation) {
                $previous = Get-TokenIdentity -Token $tokens[$previousIndex] -Normalizations $Normalizations
                break
            }
        }

        $next = '<END>'
        for ($nextIndex = $index + 1; $nextIndex -lt $tokens.Count; $nextIndex++) {
            if ((Test-IsSemanticToken -Token $tokens[$nextIndex]) -and
                $tokens[$nextIndex].Kind -ne [System.Management.Automation.Language.TokenKind]::LineContinuation) {
                $next = Get-TokenIdentity -Token $tokens[$nextIndex] -Normalizations $Normalizations
                break
            }
        }

        $entries.Add(('{0}|PREV={1}|NEXT={2}' -f
            (ConvertTo-NormalizedNewline -Value ([string] $tokens[$index].Text)),
            $previous,
            $next))
    }

    $entryArray = $entries.ToArray()
    return [pscustomobject][ordered]@{
        Hash = Get-TextFingerprint -Entries $entryArray
        Count = $entryArray.Count
        Entries = $entryArray
    }
}

function Get-DynamicInvocationFingerprint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $ParsedScript,
        [hashtable] $Normalizations
    )

    $entries = New-Object 'System.Collections.Generic.List[string]'
    $commands = @($ParsedScript.Ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.CommandAst]
    }, $true))

    foreach ($command in $commands) {
        if ($command.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Unknown) {
            continue
        }

        $tokens = New-Object 'System.Collections.Generic.List[string]'
        foreach ($token in $ParsedScript.Tokens) {
            if (-not (Test-IsSemanticToken -Token $token)) {
                continue
            }
            if ($token.Extent.StartOffset -ge $command.Extent.StartOffset -and
                $token.Extent.EndOffset -le $command.Extent.EndOffset) {
                $tokens.Add((Get-TokenIdentity -Token $token -Normalizations $Normalizations))
            }
        }

        $redirections = New-Object 'System.Collections.Generic.List[string]'
        foreach ($redirection in @($command.Redirections)) {
            $redirections.Add(('{0}|{1}' -f
                $redirection.GetType().FullName,
                (ConvertTo-NormalizedNewline -Value ([string] $redirection.Extent.Text))))
        }

        $entries.Add(('{0}|TOKENS={1}|REDIRECTIONS={2}' -f
            $command.InvocationOperator,
            ([string]::Join(';', $tokens.ToArray())),
            ([string]::Join(';', $redirections.ToArray()))))
    }

    $entryArray = $entries.ToArray()
    return [pscustomobject][ordered]@{
        Hash = Get-TextFingerprint -Entries $entryArray
        Count = $entryArray.Count
        Entries = $entryArray
    }
}

function Get-CommandRecords {
    param([Parameter(Mandatory)] $ParsedScript)

    $commands = @($ParsedScript.Ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.CommandAst]
    }, $true))
    $records = New-Object 'System.Collections.Generic.List[object]'
    for ($index = 0; $index -lt $commands.Count; $index++) {
        $command = $commands[$index]
        $name = $command.GetCommandName()
        if ($null -eq $name -or $command.CommandElements.Count -eq 0) {
            continue
        }
        $records.Add([pscustomobject]@{
            Index = $index
            Name = [string] $name
            Ast = $command
            NameOffset = $command.CommandElements[0].Extent.StartOffset
        })
    }
    return $records.ToArray()
}

function Add-CommandMapEntry {
    param(
        [Parameter(Mandatory)] $State,
        [Parameter(Mandatory)] $BeforeScript,
        [Parameter(Mandatory)] $AfterScript,
        [Parameter(Mandatory)] $Row,
        [Parameter(Mandatory)] [ValidateSet('Alias', 'Command')] [string] $Type
    )

    $oldName = [string] (Get-PropertyValue -InputObject $Row -Name 'OldName')
    $newName = [string] (Get-PropertyValue -InputObject $Row -Name 'NewName')
    $occurrenceValue = Get-PropertyValue -InputObject $Row -Name 'Occurrence'
    $occurrence = 0
    if (-not [int]::TryParse([string] $occurrenceValue, [ref] $occurrence) -or $occurrence -lt 1 -or
        [string]::IsNullOrWhiteSpace($oldName) -or [string]::IsNullOrWhiteSpace($newName)) {
        $State.Failures.Add("$Type mapping is incomplete or has an invalid occurrence.")
        return
    }

    $beforeRecords = @(Get-CommandRecords -ParsedScript $BeforeScript)
    $afterRecords = @(Get-CommandRecords -ParsedScript $AfterScript)
    if ($Type -eq 'Command') {
        $matches = @($beforeRecords | Where-Object { $_.Name -ceq $oldName })
    }
    else {
        $matches = @($beforeRecords | Where-Object { $_.Name -ieq $oldName })
    }
    if ($matches.Count -lt $occurrence) {
        $State.Failures.Add("$Type mapping '$oldName' occurrence $occurrence does not exist in the before source.")
        return
    }

    $beforeRecord = $matches[$occurrence - 1]
    if ($beforeRecord.Index -ge $afterRecords.Count) {
        $State.Failures.Add("$Type mapping '$oldName' occurrence $occurrence has no corresponding after command.")
        return
    }
    $afterRecord = $afterRecords[$beforeRecord.Index]
    if ($afterRecord.Name -cne $newName) {
        $State.Failures.Add("$Type mapping '$oldName' occurrence $occurrence does not map to '$newName' at the same callsite.")
        return
    }

    if ($Type -eq 'Alias') {
        $alias = @(Get-Alias -ErrorAction SilentlyContinue | Where-Object Name -CEQ $oldName)
        $replacement = @(Get-Command -ListImported -CommandType Cmdlet -ErrorAction SilentlyContinue |
            Where-Object Name -CEQ $newName)
        if ($alias.Count -ne 1 -or $replacement.Count -ne 1 -or
            $replacement[0].CommandType -eq [System.Management.Automation.CommandTypes]::Alias -or
            $alias[0].ResolvedCommandName -ine $replacement[0].Name) {
            $State.Failures.Add("Alias mapping '$oldName' to '$newName' does not resolve to one canonical command.")
            return
        }
        $canonicalName = [string] $replacement[0].Name
    }
    else {
        $importedCmdlets = @(Get-Command -ListImported -CommandType Cmdlet -ErrorAction SilentlyContinue)
        $beforeCommand = @($importedCmdlets | Where-Object Name -IEQ $oldName)
        $afterCommand = @($importedCmdlets | Where-Object Name -CEQ $newName)
        if ($beforeCommand.Count -ne 1 -or $afterCommand.Count -ne 1 -or
            $beforeCommand[0].CommandType -eq [System.Management.Automation.CommandTypes]::Alias -or
            $afterCommand[0].CommandType -eq [System.Management.Automation.CommandTypes]::Alias -or
            $beforeCommand[0].Name -ine $afterCommand[0].Name -or
            $afterCommand[0].Name -cne $newName) {
            $State.Failures.Add("Command mapping '$oldName' to '$newName' is not an explicit canonical-casing rewrite.")
            return
        }
        $canonicalName = [string] $afterCommand[0].Name
    }

    $beforeOffset = [string] $beforeRecord.NameOffset
    $afterOffset = [string] $afterRecord.NameOffset
    if ($State.Before.ContainsKey($beforeOffset) -or $State.After.ContainsKey($afterOffset)) {
        $State.Failures.Add("$Type mapping '$oldName' occurrence $occurrence overlaps another mapping.")
        return
    }

    $State.Before[$beforeOffset] = $canonicalName
    $State.After[$afterOffset] = $canonicalName
    $State.Applied.Add([pscustomobject][ordered]@{
        Type = $Type
        OldName = $oldName
        NewName = $newName
        Occurrence = $occurrence
    })
}

function Resolve-AliasMapping {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $BeforeScript,
        [Parameter(Mandatory)] $AfterScript,
        $SymbolMap
    )

    $state = [pscustomobject]@{
        Before = @{}
        After = @{}
        BeforeFunctionNames = @{}
        AfterFunctionNames = @{}
        Applied = New-Object 'System.Collections.Generic.List[object]'
        Failures = New-Object 'System.Collections.Generic.List[string]'
    }

    foreach ($row in @(Get-MapRows -SymbolMap $SymbolMap -Name 'Commands')) {
        Add-CommandMapEntry -State $state -BeforeScript $BeforeScript -AfterScript $AfterScript -Row $row -Type Command
    }
    foreach ($row in @(Get-MapRows -SymbolMap $SymbolMap -Name 'Aliases')) {
        Add-CommandMapEntry -State $state -BeforeScript $BeforeScript -AfterScript $AfterScript -Row $row -Type Alias
    }

    return $state
}

function Get-FunctionNameOffset {
    param(
        [Parameter(Mandatory)] $ParsedScript,
        [Parameter(Mandatory)] $Function
    )

    foreach ($token in $ParsedScript.Tokens) {
        if ($token.Extent.StartOffset -le $Function.Extent.StartOffset -or
            $token.Extent.EndOffset -gt $Function.Body.Extent.StartOffset) {
            continue
        }
        if ($token.Text -ceq $Function.Name) {
            return $token.Extent.StartOffset
        }
    }

    return -1
}

function Test-FunctionRenameMapping {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $BeforeScript,
        [Parameter(Mandatory)] $AfterScript,
        $SymbolMap,
        [Parameter(Mandatory)] $State
    )

    $beforeFunctions = @($BeforeScript.Ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
    }, $true))
    $afterFunctions = @($AfterScript.Ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
    }, $true))
    $beforeCommands = @(Get-CommandRecords -ParsedScript $BeforeScript)
    $afterCommands = @(Get-CommandRecords -ParsedScript $AfterScript)

    foreach ($row in @(Get-MapRows -SymbolMap $SymbolMap -Name 'Functions')) {
        $oldName = [string] (Get-PropertyValue -InputObject $row -Name 'OldName')
        $newName = [string] (Get-PropertyValue -InputObject $row -Name 'NewName')
        if ([string]::IsNullOrWhiteSpace($oldName) -or [string]::IsNullOrWhiteSpace($newName)) {
            $State.Failures.Add('Function mapping is incomplete.')
            continue
        }

        $oldDefinitions = @($beforeFunctions | Where-Object { $_.Name -ieq $oldName })
        $newDefinitions = @($afterFunctions | Where-Object { $_.Name -ieq $newName })
        if ($oldDefinitions.Count -ne 1 -or $newDefinitions.Count -ne 1) {
            $State.Failures.Add("Function mapping '$oldName' to '$newName' requires exactly one definition on each side.")
            continue
        }

        $beforeDefinitionIndex = [array]::IndexOf($beforeFunctions, $oldDefinitions[0])
        $afterDefinitionIndex = [array]::IndexOf($afterFunctions, $newDefinitions[0])
        if ($beforeDefinitionIndex -ne $afterDefinitionIndex) {
            $State.Failures.Add("Function mapping '$oldName' to '$newName' changes definition order.")
            continue
        }

        $beforeNameOffset = Get-FunctionNameOffset -ParsedScript $BeforeScript -Function $oldDefinitions[0]
        $afterNameOffset = Get-FunctionNameOffset -ParsedScript $AfterScript -Function $newDefinitions[0]
        if ($beforeNameOffset -lt 0 -or $afterNameOffset -lt 0) {
            $State.Failures.Add("Function mapping '$oldName' to '$newName' could not identify both definition tokens.")
            continue
        }

        $oldCalls = @($beforeCommands | Where-Object { $_.Name -ieq $oldName })
        $newCalls = @($afterCommands | Where-Object { $_.Name -ieq $newName })
        if ($oldCalls.Count -ne $newCalls.Count) {
            $State.Failures.Add("Function mapping '$oldName' to '$newName' does not preserve the static callsite count.")
            continue
        }

        $validCallsites = $true
        for ($index = 0; $index -lt $oldCalls.Count; $index++) {
            $beforeCall = $oldCalls[$index]
            if ($beforeCall.Index -ge $afterCommands.Count -or
                $afterCommands[$beforeCall.Index].Name -cne $newName) {
                $State.Failures.Add("Function mapping '$oldName' to '$newName' is not a static callsite bijection.")
                $validCallsites = $false
                break
            }
        }
        if (-not $validCallsites) {
            continue
        }

        $canonicalName = $newName
        $State.Before[[string] $beforeNameOffset] = [pscustomobject]@{
            Kind = 'MappedFunctionDefinition'
            Flags = 'None'
            Value = $canonicalName
        }
        $State.After[[string] $afterNameOffset] = [pscustomobject]@{
            Kind = 'MappedFunctionDefinition'
            Flags = 'None'
            Value = $canonicalName
        }
        for ($index = 0; $index -lt $oldCalls.Count; $index++) {
            $State.Before[[string] $oldCalls[$index].NameOffset] = [pscustomobject]@{
                Kind = 'MappedFunctionCall'
                Flags = 'CommandName'
                Value = $canonicalName
            }
            $State.After[[string] $afterCommands[$oldCalls[$index].Index].NameOffset] = [pscustomobject]@{
                Kind = 'MappedFunctionCall'
                Flags = 'CommandName'
                Value = $canonicalName
            }
        }
        $State.BeforeFunctionNames[$oldName.ToLowerInvariant()] = $canonicalName
        $State.AfterFunctionNames[$newName.ToLowerInvariant()] = $canonicalName

        $symbolPattern = '(?i)(?<![A-Za-z0-9_-])' + [regex]::Escape($oldName) + '(?![A-Za-z0-9_-])'
        foreach ($token in $BeforeScript.Tokens) {
            if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::EndOfInput) {
                continue
            }
            if ([regex]::IsMatch([string] $token.Text, $symbolPattern) -and
                -not $State.Before.ContainsKey([string] $token.Extent.StartOffset)) {
                $State.Failures.Add("Function mapping '$oldName' has an ambiguous or dynamic reference in the before source.")
                break
            }
        }
        if ([regex]::IsMatch($AfterScript.Text, $symbolPattern)) {
            $State.Failures.Add("After source contains unresolved old function symbol '$oldName'.")
        }

        $State.Applied.Add([pscustomobject][ordered]@{
            Type = 'Function'
            OldName = $oldName
            NewName = $newName
            Occurrence = $null
            StaticCallsites = $oldCalls.Count
        })
    }

    return $State
}

function New-FingerprintSummary {
    param($Before, $After)

    if ($null -eq $Before -or $null -eq $After) {
        return $null
    }

    $summary = [ordered]@{
        Before = $Before.Hash
        After = $After.Hash
        BeforeCount = $Before.Count
        AfterCount = $After.Count
    }
    if ($null -ne $Before.PSObject.Properties['HelpCount']) {
        $summary.BeforeHelpCount = $Before.HelpCount
        $summary.AfterHelpCount = $After.HelpCount
    }
    return [pscustomobject] $summary
}

function New-RewriteReportRow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $BeforePath,
        [Parameter(Mandatory)] [string] $AfterPath,
        [Parameter(Mandatory)] $BeforeScript,
        [Parameter(Mandatory)] $AfterScript,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [string[]] $Failures,
        $AppliedMapEntries,
        $AstBefore,
        $AstAfter,
        $TokensBefore,
        $TokensAfter,
        $CommentsBefore,
        $CommentsAfter,
        $HereStringsBefore,
        $HereStringsAfter,
        $ContinuationsBefore,
        $ContinuationsAfter,
        $DynamicBefore,
        $DynamicAfter
    )

    $beforeParserErrors = @($BeforeScript.Errors | ForEach-Object {
        [pscustomobject][ordered]@{
            Message = $_.Message
            ErrorId = $_.ErrorId
            StartLine = $_.Extent.StartLineNumber
            StartColumn = $_.Extent.StartColumnNumber
        }
    })
    $afterParserErrors = @($AfterScript.Errors | ForEach-Object {
        [pscustomobject][ordered]@{
            Message = $_.Message
            ErrorId = $_.ErrorId
            StartLine = $_.Extent.StartLineNumber
            StartColumn = $_.Extent.StartColumnNumber
        }
    })

    return [pscustomobject][ordered]@{
        BasePath = $BeforePath
        NewPath = $AfterPath
        Passed = $Failures.Count -eq 0
        Failures = @($Failures)
        ByteHashes = [pscustomobject][ordered]@{
            Before = $BeforeScript.ByteHash
            After = $AfterScript.ByteHash
        }
        ParserErrors = [pscustomobject][ordered]@{
            Before = $beforeParserErrors
            After = $afterParserErrors
        }
        Fingerprints = [pscustomobject][ordered]@{
            AstShape = New-FingerprintSummary -Before $AstBefore -After $AstAfter
            SemanticTokens = New-FingerprintSummary -Before $TokensBefore -After $TokensAfter
            Comments = New-FingerprintSummary -Before $CommentsBefore -After $CommentsAfter
            HereStrings = New-FingerprintSummary -Before $HereStringsBefore -After $HereStringsAfter
            LineContinuations = New-FingerprintSummary -Before $ContinuationsBefore -After $ContinuationsAfter
            DynamicInvocations = New-FingerprintSummary -Before $DynamicBefore -After $DynamicAfter
        }
        AppliedMapEntries = @($AppliedMapEntries)
        SensitiveConstructs = [pscustomobject][ordered]@{
            BeforeComments = if ($null -eq $CommentsBefore) { 0 } else { $CommentsBefore.Count }
            AfterComments = if ($null -eq $CommentsAfter) { 0 } else { $CommentsAfter.Count }
            BeforeHelpBlocks = if ($null -eq $CommentsBefore) { 0 } else { $CommentsBefore.HelpCount }
            AfterHelpBlocks = if ($null -eq $CommentsAfter) { 0 } else { $CommentsAfter.HelpCount }
            BeforeHereStrings = if ($null -eq $HereStringsBefore) { 0 } else { $HereStringsBefore.Count }
            AfterHereStrings = if ($null -eq $HereStringsAfter) { 0 } else { $HereStringsAfter.Count }
            BeforeLineContinuations = if ($null -eq $ContinuationsBefore) { 0 } else { $ContinuationsBefore.Count }
            AfterLineContinuations = if ($null -eq $ContinuationsAfter) { 0 } else { $ContinuationsAfter.Count }
            BeforeDynamicInvocations = if ($null -eq $DynamicBefore) { 0 } else { $DynamicBefore.Count }
            AfterDynamicInvocations = if ($null -eq $DynamicAfter) { 0 } else { $DynamicAfter.Count }
        }
    }
}

function Compare-PowerShellSource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $BeforePath,
        [Parameter(Mandatory)] [string] $AfterPath,
        $SymbolMap = @{},
        [byte[]] $BeforeBytes,
        [byte[]] $AfterBytes
    )

    $beforeScript = Get-ParsedScript -Path $BeforePath -Bytes $BeforeBytes
    $afterScript = Get-ParsedScript -Path $AfterPath -Bytes $AfterBytes
    $failures = New-Object 'System.Collections.Generic.List[string]'

    if ($beforeScript.Errors.Count -gt 0) {
        $failures.Add('Before source contains parser errors.')
    }
    if ($afterScript.Errors.Count -gt 0) {
        $failures.Add('After source contains parser errors.')
    }

    $astBefore = $null
    $astAfter = $null
    $tokensBefore = $null
    $tokensAfter = $null
    $commentsBefore = $null
    $commentsAfter = $null
    $hereStringsBefore = $null
    $hereStringsAfter = $null
    $continuationsBefore = $null
    $continuationsAfter = $null
    $dynamicBefore = $null
    $dynamicAfter = $null
    $applied = @()

    if ($beforeScript.Errors.Count -eq 0 -and $afterScript.Errors.Count -eq 0) {
        $state = Resolve-AliasMapping -BeforeScript $beforeScript -AfterScript $afterScript -SymbolMap $SymbolMap
        $state = Test-FunctionRenameMapping `
            -BeforeScript $beforeScript `
            -AfterScript $afterScript `
            -SymbolMap $SymbolMap `
            -State $state
        foreach ($failure in $state.Failures) {
            $failures.Add($failure)
        }
        $applied = $state.Applied.ToArray()

        $astBefore = Get-AstShapeFingerprint -ParsedScript $beforeScript
        $astAfter = Get-AstShapeFingerprint -ParsedScript $afterScript
        if ($astBefore.Hash -cne $astAfter.Hash) {
            $failures.Add('AST shape fingerprint differs.')
        }

        $tokensBefore = Get-SemanticTokenFingerprint -ParsedScript $beforeScript -Normalizations $state.Before
        $tokensAfter = Get-SemanticTokenFingerprint -ParsedScript $afterScript -Normalizations $state.After
        if ($tokensBefore.Hash -cne $tokensAfter.Hash) {
            $failures.Add('Semantic token fingerprint differs.')
        }

        $commentsBefore = Get-CommentAnchorFingerprint `
            -ParsedScript $beforeScript `
            -Normalizations $state.Before `
            -FunctionNames $state.BeforeFunctionNames
        $commentsAfter = Get-CommentAnchorFingerprint `
            -ParsedScript $afterScript `
            -Normalizations $state.After `
            -FunctionNames $state.AfterFunctionNames
        if ($commentsBefore.Hash -cne $commentsAfter.Hash) {
            $failures.Add('Comment anchor or help fingerprint differs.')
        }

        $hereStringsBefore = Get-HereStringFingerprint -ParsedScript $beforeScript
        $hereStringsAfter = Get-HereStringFingerprint -ParsedScript $afterScript
        if ($hereStringsBefore.Hash -cne $hereStringsAfter.Hash) {
            $failures.Add('Here-string fingerprint differs.')
        }

        $continuationsBefore = Get-LineContinuationFingerprint -ParsedScript $beforeScript -Normalizations $state.Before
        $continuationsAfter = Get-LineContinuationFingerprint -ParsedScript $afterScript -Normalizations $state.After
        if ($continuationsBefore.Hash -cne $continuationsAfter.Hash) {
            $failures.Add('Line-continuation fingerprint differs.')
        }

        $dynamicBefore = Get-DynamicInvocationFingerprint -ParsedScript $beforeScript -Normalizations $state.Before
        $dynamicAfter = Get-DynamicInvocationFingerprint -ParsedScript $afterScript -Normalizations $state.After
        if ($dynamicBefore.Hash -cne $dynamicAfter.Hash) {
            $failures.Add('Dynamic-invocation fingerprint differs.')
        }
    }

    $uniqueFailures = @($failures | Select-Object -Unique)
    return New-RewriteReportRow `
        -BeforePath $BeforePath `
        -AfterPath $AfterPath `
        -BeforeScript $beforeScript `
        -AfterScript $afterScript `
        -Failures $uniqueFailures `
        -AppliedMapEntries $applied `
        -AstBefore $astBefore `
        -AstAfter $astAfter `
        -TokensBefore $tokensBefore `
        -TokensAfter $tokensAfter `
        -CommentsBefore $commentsBefore `
        -CommentsAfter $commentsAfter `
        -HereStringsBefore $hereStringsBefore `
        -HereStringsAfter $hereStringsAfter `
        -ContinuationsBefore $continuationsBefore `
        -ContinuationsAfter $continuationsAfter `
        -DynamicBefore $dynamicBefore `
        -DynamicAfter $dynamicAfter
}

function Test-PathMapBijection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [object[]] $Rows,
        [Parameter(Mandatory)] [ValidateRange(0, [int]::MaxValue)] [int] $ExpectedCount
    )

    if ($Rows.Count -ne $ExpectedCount) {
        return $false
    }

    $basePaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $newPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($row in $Rows) {
        $basePath = [string] (Get-PropertyValue -InputObject $row -Name 'BasePath')
        $newPath = [string] (Get-PropertyValue -InputObject $row -Name 'NewPath')
        foreach ($path in @($basePath, $newPath)) {
            if ([string]::IsNullOrWhiteSpace($path) -or
                [System.IO.Path]::IsPathRooted($path) -or
                $path.Contains('\') -or
                $path.Contains('"') -or
                @($path.Split('/') | Where-Object { $_ -eq '..' -or $_ -eq '.' }).Count -gt 0) {
                return $false
            }
        }

        if (-not $basePaths.Add($basePath) -or -not $newPaths.Add($newPath)) {
            return $false
        }
    }

    return $basePaths.Count -eq $ExpectedCount -and $newPaths.Count -eq $ExpectedCount
}

Export-ModuleMember -Function @(
    'Compare-PowerShellSource'
    'Test-PathMapBijection'
)
