function IsMember {
    param([string] $Group)

    return $Group -eq 'Administrators'
}

IsMember -Group 'Administrators'
& (Write-Output ('Is' + 'Member') 'Get-Date' | Select-Object -Last 1)
