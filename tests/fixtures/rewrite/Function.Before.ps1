function IsMember {
    param([string] $Group)

    return $Group -eq 'Administrators'
}

IsMember -Group 'Administrators'
