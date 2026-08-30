[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $PathMap,
    [Parameter(Mandatory)] [string] $Metadata,
    [Parameter(Mandatory)] [string] $Schema,
    [string] $OutputRoot = (Join-Path $PSScriptRoot '..')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-QuotedPsd1String {
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $Value)

    return "'$($Value.Replace("'", "''"))'"
}

function ConvertTo-Psd1StringArray {
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Value)

    if ($Value.Count -eq 0) {
        return '@()'
    }

    $quoted = @($Value | ForEach-Object { ConvertTo-QuotedPsd1String -Value ([string] $_) })
    return '@(' + ($quoted -join ', ') + ')'
}

function Assert-MetadataKey {
    param(
        [Parameter(Mandatory)] [System.Collections.IDictionary] $Value,
        [Parameter(Mandatory)] [string] $Key,
        [Parameter(Mandatory)] [string] $Context
    )

    if (-not $Value.Contains($Key)) {
        throw "$Context.$Key metadata is required."
    }

    return , ($Value[$Key])
}

function Assert-NonEmptyString {
    param(
        [Parameter(Mandatory)] [AllowNull()] [object] $Value,
        [Parameter(Mandatory)] [string] $Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty String."
    }

    if ($Value -match '(?i)<[^>]+>|^\s*(?:TBD|TODO|UNKNOWN|PLACEHOLDER|SENTINEL)\s*$') {
        throw "$Context contains sentinel metadata."
    }
}

function Assert-Boolean {
    param(
        [Parameter(Mandatory)] [AllowNull()] [object] $Value,
        [Parameter(Mandatory)] [string] $Context
    )

    if ($Value -isnot [bool]) {
        throw "$Context must be Boolean."
    }
}

function Assert-StringArray {
    param(
        [Parameter(Mandatory)] [AllowNull()] [object] $Value,
        [Parameter(Mandatory)] [string] $Context,
        [switch] $AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -isnot [System.Collections.IEnumerable]) {
        throw "$Context must be an array of strings."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must contain at least one string."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context $Context
    }
}

function Assert-EnumValue {
    param(
        [Parameter(Mandatory)] [AllowNull()] [object] $Value,
        [Parameter(Mandatory)] [object[]] $Allowed,
        [Parameter(Mandatory)] [string] $Context
    )

    Assert-NonEmptyString -Value $Value -Context $Context
    if ($Value -cnotin $Allowed) {
        throw "$Context value '$Value' is not allowed."
    }
}

function Assert-ScriptMetadata {
    param(
        [Parameter(Mandatory)] [System.Collections.IDictionary] $Record,
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [ValidateSet('Detection', 'Remediation')] [string] $Role,
        [Parameter(Mandatory)] [System.Collections.IDictionary] $ManifestSchema
    )

    $version = Assert-MetadataKey -Value $Record -Key 'Version' -Context $Path
    Assert-NonEmptyString -Value $version -Context "$Path.Version"
    if ($version -notmatch '^\d+\.\d+\.\d+$') {
        throw "$Path.Version must be a three-part semantic version."
    }

    $description = Assert-MetadataKey -Value $Record -Key 'Description' -Context $Path
    Assert-NonEmptyString -Value $description -Context "$Path.Description"

    $authors = Assert-MetadataKey -Value $Record -Key 'Authors' -Context $Path
    Assert-StringArray -Value $authors -Context "$Path.Authors"

    $runtime = Assert-MetadataKey -Value $Record -Key 'Runtime' -Context $Path
    if ($runtime -isnot [System.Collections.IDictionary]) {
        throw "$Path.Runtime metadata must be a hashtable."
    }
    $runAs = Assert-MetadataKey -Value $runtime -Key 'RunAs' -Context "$Path.Runtime"
    Assert-EnumValue -Value $runAs -Allowed $ManifestSchema.Enums.RunAs -Context "$Path.Runtime.RunAs"
    Assert-Boolean -Value (Assert-MetadataKey -Value $runtime -Key 'RequiresElevation' -Context "$Path.Runtime") -Context "$Path.Runtime.RequiresElevation"
    Assert-EnumValue -Value (Assert-MetadataKey -Value $runtime -Key 'SignatureCheck' -Context "$Path.Runtime") -Allowed $ManifestSchema.Enums.SignatureCheck -Context "$Path.Runtime.SignatureCheck"
    Assert-StringArray -Value (Assert-MetadataKey -Value $runtime -Key 'SupportedWindows' -Context "$Path.Runtime") -Context "$Path.Runtime.SupportedWindows"
    Assert-EnumValue -Value (Assert-MetadataKey -Value $runtime -Key 'Reboot' -Context "$Path.Runtime") -Allowed $ManifestSchema.Enums.Reboot -Context "$Path.Runtime.Reboot"

    $behavior = Assert-MetadataKey -Value $Record -Key 'Behavior' -Context $Path
    if ($behavior -isnot [System.Collections.IDictionary]) {
        throw "$Path.Behavior metadata must be a hashtable."
    }
    $detectionMode = Assert-MetadataKey -Value $behavior -Key 'DetectionMode' -Context "$Path.Behavior"
    Assert-EnumValue -Value $detectionMode -Allowed $ManifestSchema.Enums.DetectionMode -Context "$Path.Behavior.DetectionMode"
    if ($Role -eq 'Detection' -and $detectionMode -eq 'NotApplicable') {
        throw "$Path detection metadata requires an applicable DetectionMode."
    }
    if ($Role -eq 'Remediation' -and $detectionMode -ne 'NotApplicable') {
        throw "$Path remediation metadata requires DetectionMode 'NotApplicable'."
    }

    $dependencies = Assert-MetadataKey -Value $Record -Key 'Dependencies' -Context $Path
    if ($dependencies -isnot [System.Collections.IDictionary]) {
        throw "$Path.Dependencies metadata must be a hashtable."
    }
    foreach ($name in 'Modules', 'Cmdlets', 'Executables', 'Policies', 'Endpoints') {
        Assert-StringArray -Value (Assert-MetadataKey -Value $dependencies -Key $name -Context "$Path.Dependencies") -Context "$Path.Dependencies.$name" -AllowEmpty
    }

    $configuration = Assert-MetadataKey -Value $Record -Key 'Configuration' -Context $Path
    if ($null -eq $configuration -or $configuration -is [string] -or $configuration -isnot [System.Collections.IEnumerable]) {
        throw "$Path.Configuration metadata must be an array."
    }
    foreach ($setting in @($configuration)) {
        if ($setting -isnot [System.Collections.IDictionary]) {
            throw "$Path.Configuration entries must be hashtables."
        }
        Assert-NonEmptyString -Value (Assert-MetadataKey -Value $setting -Key 'Name' -Context "$Path.Configuration") -Context "$Path.Configuration.Name"
        Assert-Boolean -Value (Assert-MetadataKey -Value $setting -Key 'Required' -Context "$Path.Configuration") -Context "$Path.Configuration.Required"
        $secret = Assert-MetadataKey -Value $setting -Key 'Secret' -Context "$Path.Configuration"
        Assert-Boolean -Value $secret -Context "$Path.Configuration.Secret"
        Assert-NonEmptyString -Value (Assert-MetadataKey -Value $setting -Key 'Description' -Context "$Path.Configuration") -Context "$Path.Configuration.Description"
        if ($secret -and $setting.Contains('Value')) {
            throw "$Path.Configuration secret '$($setting.Name)' must not store a Value."
        }
    }

    $risk = Assert-MetadataKey -Value $Record -Key 'Risk' -Context $Path
    if ($risk -isnot [System.Collections.IDictionary]) {
        throw "$Path.Risk metadata must be a hashtable."
    }
    Assert-EnumValue -Value (Assert-MetadataKey -Value $risk -Key 'Level' -Context "$Path.Risk") -Allowed $ManifestSchema.Enums.RiskLevel -Context "$Path.Risk.Level"
    Assert-Boolean -Value (Assert-MetadataKey -Value $risk -Key 'Destructive' -Context "$Path.Risk") -Context "$Path.Risk.Destructive"
    foreach ($name in 'UserImpact', 'Rollback', 'DataHandling') {
        Assert-NonEmptyString -Value (Assert-MetadataKey -Value $risk -Key $name -Context "$Path.Risk") -Context "$Path.Risk.$name"
    }

    $test = Assert-MetadataKey -Value $Record -Key 'Test' -Context $Path
    if ($test -isnot [System.Collections.IDictionary]) {
        throw "$Path.Test metadata must be a hashtable."
    }
    $categories = Assert-MetadataKey -Value $test -Key 'Categories' -Context "$Path.Test"
    Assert-StringArray -Value $categories -Context "$Path.Test.Categories"
    foreach ($category in @($categories)) {
        Assert-EnumValue -Value $category -Allowed $ManifestSchema.Enums.TestCategory -Context "$Path.Test.Categories"
    }
    Assert-EnumValue -Value (Assert-MetadataKey -Value $test -Key 'IntegrationLevel' -Context "$Path.Test") -Allowed $ManifestSchema.Enums.IntegrationLevel -Context "$Path.Test.IntegrationLevel"
    Assert-Boolean -Value (Assert-MetadataKey -Value $test -Key 'RequiresIntunePilot' -Context "$Path.Test") -Context "$Path.Test.RequiresIntunePilot"
    Assert-Boolean -Value (Assert-MetadataKey -Value $test -Key 'RequiresInteractiveUser' -Context "$Path.Test") -Context "$Path.Test.RequiresInteractiveUser"
}

function ConvertTo-MetadataRecord {
    param(
        [Parameter(Mandatory)] [object[]] $Values,
        [Parameter(Mandatory)] [int] $Offset
    )

    $context = "ScriptMetadata record at offset $Offset"
    $runtime = @($Values[$Offset + 4])
    $dependencies = @($Values[$Offset + 6])
    $configurationValues = @($Values[$Offset + 7])
    $risk = @($Values[$Offset + 8])
    $test = @($Values[$Offset + 9])
    if ($runtime.Count -ne 5) {
        throw "$context Runtime must contain exactly 5 values."
    }
    if ($dependencies.Count -ne 5) {
        throw "$context Dependencies must contain exactly 5 arrays."
    }
    if ($configurationValues.Count % 4 -ne 0) {
        throw "$context Configuration must contain groups of 4 values."
    }
    if ($risk.Count -ne 5) {
        throw "$context Risk must contain exactly 5 values."
    }
    if ($test.Count -ne 4) {
        throw "$context Test must contain exactly 4 values."
    }

    $configuration = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $configurationValues.Count; $index += 4) {
        $configuration.Add(@{
                Name = $configurationValues[$index]
                Required = $configurationValues[$index + 1]
                Secret = $configurationValues[$index + 2]
                Description = $configurationValues[$index + 3]
            })
    }

    return @{
        Version = $Values[$Offset + 1]
        Description = $Values[$Offset + 2]
        Authors = @($Values[$Offset + 3])
        Runtime = @{
            RunAs = $runtime[0]
            RequiresElevation = $runtime[1]
            SignatureCheck = $runtime[2]
            SupportedWindows = @($runtime[3])
            Reboot = $runtime[4]
        }
        Behavior = @{ DetectionMode = $Values[$Offset + 5] }
        Dependencies = @{
            Modules = @($dependencies[0])
            Cmdlets = @($dependencies[1])
            Executables = @($dependencies[2])
            Policies = @($dependencies[3])
            Endpoints = @($dependencies[4])
        }
        Configuration = @($configuration)
        Risk = @{
            Level = $risk[0]
            Destructive = $risk[1]
            UserImpact = $risk[2]
            Rollback = $risk[3]
            DataHandling = $risk[4]
        }
        Test = @{
            Categories = @($test[0])
            IntegrationLevel = $test[1]
            RequiresIntunePilot = $test[2]
            RequiresInteractiveUser = $test[3]
        }
    }
}

function ConvertTo-ScriptMetadataIndex {
    param([Parameter(Mandatory)] [AllowNull()] [object] $Value)

    if ($Value -is [System.Collections.IDictionary]) {
        return $Value
    }
    if ($null -eq $Value -or $Value -is [string] -or $Value -isnot [System.Collections.IEnumerable]) {
        throw 'ScriptMetadata must be a hashtable or an array of 10-value metadata records.'
    }

    $recordSize = 10
    $metadataByPath = @{}
    $recordIndex = 0
    foreach ($recordValue in @($Value)) {
        $values = @($recordValue)
        if ($values.Count -ne $recordSize) {
            throw "ScriptMetadata record $recordIndex must contain exactly $recordSize values."
        }

        $path = $values[0]
        Assert-NonEmptyString -Value $path -Context "ScriptMetadata[$recordIndex].Path"
        if ($metadataByPath.ContainsKey($path)) {
            throw "Duplicate ScriptMetadata path '$path'."
        }

        $metadataByPath[$path] = ConvertTo-MetadataRecord -Values $values -Offset 0
        $recordIndex++
    }

    return $metadataByPath
}


function New-VersionFiveGuid {
    param(
        [Parameter(Mandatory)] [guid] $Namespace,
        [Parameter(Mandatory)] [string] $Name
    )

    $namespaceBytes = $Namespace.ToByteArray()
    $networkNamespaceBytes = [byte[]] @(
        $namespaceBytes[3], $namespaceBytes[2], $namespaceBytes[1], $namespaceBytes[0],
        $namespaceBytes[5], $namespaceBytes[4], $namespaceBytes[7], $namespaceBytes[6],
        $namespaceBytes[8], $namespaceBytes[9], $namespaceBytes[10], $namespaceBytes[11],
        $namespaceBytes[12], $namespaceBytes[13], $namespaceBytes[14], $namespaceBytes[15]
    )
    $nameBytes = [Text.Encoding]::UTF8.GetBytes($Name)
    $inputBytes = [byte[]]::new($networkNamespaceBytes.Length + $nameBytes.Length)
    [Array]::Copy($networkNamespaceBytes, 0, $inputBytes, 0, $networkNamespaceBytes.Length)
    [Array]::Copy($nameBytes, 0, $inputBytes, $networkNamespaceBytes.Length, $nameBytes.Length)

    $sha1 = [Security.Cryptography.SHA1]::Create()
    try {
        $hash = $sha1.ComputeHash($inputBytes)
    }
    finally {
        $sha1.Dispose()
    }

    $uuidBytes = [byte[]]::new(16)
    [Array]::Copy($hash, $uuidBytes, 16)
    $uuidBytes[6] = [byte] (($uuidBytes[6] -band 0x0f) -bor 0x50)
    $uuidBytes[8] = [byte] (($uuidBytes[8] -band 0x3f) -bor 0x80)
    $hex = ([BitConverter]::ToString($uuidBytes)).Replace('-', '').ToLowerInvariant()
    return [guid] ($hex.Substring(0, 8) + '-' +
        $hex.Substring(8, 4) + '-' +
        $hex.Substring(12, 4) + '-' +
        $hex.Substring(16, 4) + '-' +
        $hex.Substring(20, 12))
}

function New-ManifestContent {
    param(
        [Parameter(Mandatory)] [System.Collections.IDictionary] $Manifest,
        [Parameter(Mandatory)] [System.Collections.IDictionary] $MetadataRecord
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('@{')
    $lines.Add("    SchemaVersion = $(ConvertTo-QuotedPsd1String $Manifest.SchemaVersion)")
    $lines.Add("    Id = $(ConvertTo-QuotedPsd1String $Manifest.Id)")
    $lines.Add('    Identity = @{')
    foreach ($name in 'PackageName', 'ScriptName', 'Role', 'Version', 'Description') {
        $lines.Add("        $name = $(ConvertTo-QuotedPsd1String ([string] $Manifest.Identity[$name]))")
    }
    $lines.Add("        Authors = $(ConvertTo-Psd1StringArray @($Manifest.Identity.Authors))")
    $lines.Add("        Source = $(ConvertTo-QuotedPsd1String $Manifest.Identity.Source)")
    $lines.Add("        Counterpart = $(ConvertTo-QuotedPsd1String $Manifest.Identity.Counterpart)")
    $lines.Add('    }')
    $lines.Add('    Runtime = @{')
    $lines.Add("        PowerShellVersion = '5.1'")
    $lines.Add("        Architecture = 'x64'")
    $lines.Add("        RunAs = $(ConvertTo-QuotedPsd1String $Manifest.Runtime.RunAs)")
    $lines.Add("        RequiresElevation = `$$($Manifest.Runtime.RequiresElevation.ToString().ToLowerInvariant())")
    $lines.Add("        SignatureCheck = $(ConvertTo-QuotedPsd1String $Manifest.Runtime.SignatureCheck)")
    $lines.Add("        SupportedWindows = $(ConvertTo-Psd1StringArray @($Manifest.Runtime.SupportedWindows))")
    $lines.Add("        Reboot = $(ConvertTo-QuotedPsd1String $Manifest.Runtime.Reboot)")
    $lines.Add('    }')
    $lines.Add("    Behavior = @{ DetectionMode = $(ConvertTo-QuotedPsd1String $Manifest.Behavior.DetectionMode) }")
    $lines.Add('    Dependencies = @{')
    foreach ($name in 'Modules', 'Cmdlets', 'Executables', 'Policies', 'Endpoints') {
        $lines.Add("        $name = $(ConvertTo-Psd1StringArray @($Manifest.Dependencies[$name]))")
    }
    $lines.Add('    }')
    if (@($MetadataRecord.Configuration).Count -eq 0) {
        $lines.Add('    Configuration = @()')
    }
    else {
        $lines.Add('    Configuration = @(')
        foreach ($setting in @($MetadataRecord.Configuration)) {
            $lines.Add('        @{')
            $lines.Add("            Name = $(ConvertTo-QuotedPsd1String $setting.Name)")
            $lines.Add("            Required = `$$($setting.Required.ToString().ToLowerInvariant())")
            $lines.Add("            Secret = `$$($setting.Secret.ToString().ToLowerInvariant())")
            $lines.Add("            Description = $(ConvertTo-QuotedPsd1String $setting.Description)")
            $lines.Add('        }')
        }
        $lines.Add('    )')
    }
    $lines.Add('    Risk = @{')
    $lines.Add("        Level = $(ConvertTo-QuotedPsd1String $Manifest.Risk.Level)")
    $lines.Add("        Destructive = `$$($Manifest.Risk.Destructive.ToString().ToLowerInvariant())")
    foreach ($name in 'UserImpact', 'Rollback', 'DataHandling') {
        $lines.Add("        $name = $(ConvertTo-QuotedPsd1String $Manifest.Risk[$name])")
    }
    $lines.Add('    }')
    $lines.Add('    Test = @{')
    $lines.Add("        Categories = $(ConvertTo-Psd1StringArray @($Manifest.Test.Categories))")
    $lines.Add("        Status = 'PendingMigration'")
    $lines.Add('        CoverageFloor = 0.0')
    $lines.Add("        IntegrationLevel = $(ConvertTo-QuotedPsd1String $Manifest.Test.IntegrationLevel)")
    $lines.Add("        RequiresIntunePilot = `$$($Manifest.Test.RequiresIntunePilot.ToString().ToLowerInvariant())")
    $lines.Add("        RequiresInteractiveUser = `$$($Manifest.Test.RequiresInteractiveUser.ToString().ToLowerInvariant())")
    $lines.Add('    }')
    $lines.Add('}')

    return ($lines -join "`n") + "`n"
}

$resolvedPathMap = (Resolve-Path -LiteralPath $PathMap).Path
$resolvedMetadata = (Resolve-Path -LiteralPath $Metadata).Path
$resolvedSchema = (Resolve-Path -LiteralPath $Schema).Path
$resolvedOutputRoot = [IO.Path]::GetFullPath($OutputRoot)
$pathMapData = Import-PowerShellDataFile -LiteralPath $resolvedPathMap
$metadataData = Import-PowerShellDataFile -LiteralPath $resolvedMetadata
$schemaData = Import-PowerShellDataFile -LiteralPath $resolvedSchema

if ($metadataData -isnot [System.Collections.IDictionary]) {
    throw 'Metadata must be a PowerShell data-file hashtable.'
}
if (-not $metadataData.Contains('ManifestNamespaceGuid')) {
    throw 'ManifestNamespaceGuid metadata is required.'
}
$namespaceGuid = [guid]::Empty
if (-not [guid]::TryParse([string] $metadataData.ManifestNamespaceGuid, [ref] $namespaceGuid) -or $namespaceGuid -eq [guid]::Empty) {
    throw 'ManifestNamespaceGuid metadata must be a non-empty GUID.'
}
if ($metadataData.Contains('ScriptMetadata')) {
    $scriptMetadata = $metadataData.ScriptMetadata
}
elseif ($metadataData.Contains('ScriptMetadataJson')) {
    Assert-NonEmptyString -Value $metadataData.ScriptMetadataJson -Context 'ScriptMetadataJson'
    try {
        $scriptMetadata = ConvertFrom-Json -InputObject $metadataData.ScriptMetadataJson -ErrorAction Stop
    }
    catch {
        throw "ScriptMetadataJson is invalid: $($_.Exception.Message)"
    }
}
else {
    throw 'ScriptMetadata or ScriptMetadataJson is required.'
}
$metadataByPath = ConvertTo-ScriptMetadataIndex -Value $scriptMetadata
if ($pathMapData -isnot [System.Collections.IDictionary] -or $null -eq $pathMapData.Paths) {
    throw 'PathMap must contain a Paths array.'
}

$rows = @($pathMapData.Paths)
$rowByNewPath = @{}
$rowsByPackage = @{}
foreach ($row in $rows) {
    if ($row -isnot [System.Collections.IDictionary]) {
        throw 'Every path-map row must be a hashtable.'
    }
    Assert-NonEmptyString -Value $row.BasePath -Context 'PathMap.Paths.BasePath'
    Assert-NonEmptyString -Value $row.NewPath -Context 'PathMap.Paths.NewPath'
    if ($rowByNewPath.ContainsKey($row.NewPath)) {
        throw "Duplicate path-map destination '$($row.NewPath)'."
    }
    $rowByNewPath[$row.NewPath] = $row
    $packageName = Split-Path $row.NewPath -Parent
    if (-not $rowsByPackage.ContainsKey($packageName)) {
        $rowsByPackage[$packageName] = [System.Collections.Generic.List[object]]::new()
    }
    $rowsByPackage[$packageName].Add($row)
}

$metadataPaths = [string[]] @($metadataByPath.Keys)
$mappedPaths = [string[]] @($rowByNewPath.Keys)
[Array]::Sort($metadataPaths, [StringComparer]::Ordinal)
[Array]::Sort($mappedPaths, [StringComparer]::Ordinal)
$missingMetadata = @($mappedPaths | Where-Object { -not $metadataByPath.Contains($_) })
$orphanMetadata = @($metadataPaths | Where-Object { -not $rowByNewPath.ContainsKey($_) })
if ($missingMetadata.Count -gt 0) {
    throw "Mapped script '$($missingMetadata[0])' has no reviewed metadata."
}
if ($orphanMetadata.Count -gt 0) {
    throw "Reviewed metadata '$($orphanMetadata[0])' has no mapped script."
}

$plannedFiles = [System.Collections.Generic.List[object]]::new()
foreach ($newPath in $mappedPaths) {
    $row = $rowByNewPath[$newPath]
    $packageName = Split-Path $newPath -Parent
    $scriptName = [IO.Path]::GetFileNameWithoutExtension($newPath)
    $role = if ($scriptName.StartsWith('Detect-', [StringComparison]::Ordinal)) {
        'Detection'
    }
    elseif ($scriptName.StartsWith('Remediate-', [StringComparison]::Ordinal)) {
        'Remediation'
    }
    else {
        throw "Mapped script '$newPath' does not use a standard role basename."
    }
    $expectedScriptName = if ($role -eq 'Detection') { "Detect-$packageName" } else { "Remediate-$packageName" }
    if ($scriptName -cne $expectedScriptName) {
        throw "Mapped script '$newPath' does not match package scenario '$packageName'."
    }

    $packageRows = @($rowsByPackage[$packageName])
    if ($packageRows.Count -eq 1) {
        if ($role -ne 'Detection') {
            throw "Standalone package '$packageName' must contain a detection script."
        }
        $counterpart = ''
    }
    elseif ($packageRows.Count -eq 2) {
        $packageRoles = @($packageRows | ForEach-Object {
                [IO.Path]::GetFileNameWithoutExtension($_.NewPath).Split('-')[0]
            })
        if (@($packageRoles | Sort-Object -Unique).Count -ne 2 -or 'Detect' -notin $packageRoles -or 'Remediate' -notin $packageRoles) {
            throw "Package '$packageName' must contain one detection and one remediation script."
        }
        $counterpart = @($packageRows | Where-Object NewPath -CNE $newPath)[0].NewPath
    }
    else {
        throw "Package '$packageName' maps $($packageRows.Count) scripts; only pairs or detection-only packages are allowed."
    }

    $record = $metadataByPath[$newPath]
    if ($record -isnot [System.Collections.IDictionary]) {
        throw "$newPath metadata must be a hashtable."
    }
    Assert-ScriptMetadata -Record $record -Path $newPath -Role $role -ManifestSchema $schemaData

    $manifest = @{
        SchemaVersion = [string] $schemaData.SchemaVersion
        Id = (New-VersionFiveGuid -Namespace $namespaceGuid -Name ([string] $row.BasePath)).Guid
        Identity = @{
            PackageName = $packageName
            ScriptName = $scriptName
            Role = $role
            Version = $record.Version
            Description = $record.Description
            Authors = @($record.Authors)
            Source = $row.BasePath
            Counterpart = $counterpart
        }
        Runtime = @{
            RunAs = $record.Runtime.RunAs
            RequiresElevation = $record.Runtime.RequiresElevation
            SignatureCheck = $record.Runtime.SignatureCheck
            SupportedWindows = @($record.Runtime.SupportedWindows)
            Reboot = $record.Runtime.Reboot
        }
        Behavior = @{ DetectionMode = $record.Behavior.DetectionMode }
        Dependencies = $record.Dependencies
        Risk = $record.Risk
        Test = $record.Test
    }
    $plannedFiles.Add([pscustomobject]@{
            Path = Join-Path $resolvedOutputRoot ([IO.Path]::ChangeExtension($newPath, '.psd1'))
            Content = New-ManifestContent -Manifest $manifest -MetadataRecord $record
        })
}

$utf8NoBom = [Text.UTF8Encoding]::new($false)
foreach ($plannedFile in $plannedFiles) {
    $parent = Split-Path $plannedFile.Path -Parent
    [IO.Directory]::CreateDirectory($parent) | Out-Null
    [IO.File]::WriteAllText($plannedFile.Path, $plannedFile.Content, $utf8NoBom)
}

Write-Output "Generated $($plannedFiles.Count) script manifests in '$resolvedOutputRoot'."
