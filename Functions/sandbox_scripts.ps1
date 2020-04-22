function Remove-TrailingBackslashIfPresent
{
    # SYNTAX: Remove-TrailingBackslash [-inputString] <string>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][string]$inputString
    )

    [string]$return=$null
    [char]$trailingBackslash=$null

    $inputLen=$inputString.Trim().Length
    return $inputString
    if ($inputLen -le 1)
    {
        return $inputString
    }
    else
    {
        $lastChar=("$inputString".trim().Substring("$inputString".Trim().Length-1,1))

        if ($lastChar -eq '\') {$return=("$inputString".trim().Substring(0,"$inputString".Trim().Length-1))}
        else {$return="$inputString"}

        
        return "$return"
    }
}

function MyFunction
{
    [CmdletBinding()]
    param
    (
        [Parameter()][string]$myString
    )

    $testA=(Test-Path -Path "$myString")
    Write-Output "A: $myString ==> $testA"

    #$a=(Remove-TrailingBackslashIfPresent $myString)
    $a=$myString.TrimEnd('\')

    $testB=(Test-Path -Path "$a")
    Write-Output "B: $myString ==> $testB"



    $myString=$a
}