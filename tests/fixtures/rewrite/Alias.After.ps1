[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()
Get-Process | Where-Object Name -EQ 'explorer'
