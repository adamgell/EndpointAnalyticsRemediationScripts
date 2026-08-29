function Test-GroupMembership {
    param([string] $Group)

    return $Group -eq 'Administrators'
}

Test-GroupMembership -Group 'Administrators'
