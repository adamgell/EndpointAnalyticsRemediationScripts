[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentWhitespace', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPlaceOpenBrace', '')]
param()

function Get-Thing {
    param(
        [string] $Name
    )

    if ($Name) {
        Get-Item -LiteralPath $Name
    }
}
