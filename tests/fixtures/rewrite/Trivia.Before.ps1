function Get-Thing
{
	param(
		[string] $Name
	)  

	if ($Name)
	{
		Get-Item -LiteralPath $Name
	}
}
