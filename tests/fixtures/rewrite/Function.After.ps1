function Test-GroupMembership {
    param([string] $Group)

    return $Group -eq 'Administrators'
}

Test-GroupMembership -Group 'Administrators'
& (Write-Output ('Is' + 'Member') 'Get-Date' | Select-Object -Last 1)
