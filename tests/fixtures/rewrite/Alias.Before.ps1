[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()
Get-Process | ? Name -EQ 'explorer'
