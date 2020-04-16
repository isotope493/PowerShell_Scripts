function New-UniqueSequentialFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][String]$BasePath,
        [Parameter(Mandatory=$false)][int32]$TotalDigits=4,
        [Parameter(Mandatory=$false)][int32]$StartNumber=1,
        [Parameter(Mandatory=$false)][bool]$ForceNumbering=$false
    )


    # $trailingBackslash=("$basePath".trim().Substring("$_".Length-1,1))
    # write-output $trailingBackslash
    # if (Test-Path -Path "$basePath" -and $ForceNumbering -eq $false) { return $BasePath}
    # if (!(Test-Path -Path "$basePath") -and $ForceNumbering -eq $true)
    # {

    # }

}