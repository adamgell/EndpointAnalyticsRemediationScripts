# Change multiple registry keys

Validate and set registry settings according to your needs.

## Usage and examples

Update `$RegistrySettingsToValidate` in [`Detect-Change-MultipleRegistryKeys.ps1`](Detect-Change-MultipleRegistryKeys.ps1) and [`Remediate-Change-MultipleRegistryKeys.ps1`](Remediate-Change-MultipleRegistryKeys.ps1). The detection and remediation scripts use the same `[pscustomobject]` records to validate and set the registry values.

e.g:

```powershell
$RegistrySettingsToValidate = @(
    [pscustomobject]@{
        Hive  = 'HKLM:\'
        Key   = 'SOFTWARE\Contoso\Product'
        Name  = 'ImportantKey'
        Type  = 'REG_DWORD'
        Value = 1
    },
    [pscustomobject]@{
        Hive  = 'HKLM:\'
        Key   = 'SOFTWARE\Contoso\Product'
        Name  = 'AnotherKey'
        Type  = 'REG_SZ'
        Value = "SomeValue"
    }
)
```

Allowed Values for the ```Type``` property are:

- ```REG_SZ```
- ```REG_DWORD```
- ```REG_BINARY```
- ```REG_QWORD```
- ```REG_MULTI_SZ```
- ```REG_EXPAND_SZ```
