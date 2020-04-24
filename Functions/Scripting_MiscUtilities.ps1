# Returns boolean; $true if folder (1) folder already exists or (2) folder doesn't exist but can be created; $false if it CANNOT be created.
# SYNTAX: Test-FolderCanBeCreated -TestPath [string]$TestPath
function Test-FolderCanBeCreated
{
    [CmdletBinding()]
    param
    (
        [Parameter()][string]$TestPath
    )

    if ((Test-Path -Path "$testPath")) {return $true}
    elseif (!(Test-Path -Path "$testPath"))
    {
        try
        {
            $null=((New-Item -ItemType "directory" -Path "$testPath")) 
            # Just to be safe
            if ((Test-Path -Path "$testPath") -eq $true -and (Get-ChildItem "$testPath" | Measure-Object).Count -eq 0)
            {
                $null=(Remove-Item -Path "$testPath")
                return $true
            }

            return $true
        }
        catch
        {
            return $false          
        }
    }
}

function PathIsWinDriveRoot
{
    [CmdletBinding()]
    param
    (
        [Parameter()][string]$InputString
    ) 

    if ("$InputString".trim() -match "^(\.)([\.\\]*)$")
    {
        $InputString=[System.IO.Path]::GetFullPath($InputString)
    }

    $condition_1=("$InputString".trim() -match "^[A-Za-z]:\\$")
    $condition_2=("$InputString".trim() -match "^[A-Za-z]:$")
    $condition_3=("$InputString".trim() -match "^\\$")
    $condition_4=("$InputString".trim() -match "^\\$")
    if ($condition_1 -or $condition_2 -or $condition_3 -or $condition_4)
    {
        return $true
    }
    else {return $false}
}

# SYNTAX: Get-TrimThenSubStr || Get-TrimThenSubStr [-InputString || Input] <string> [-StartPosition || Start] <string> [[-NumberOfCharacters || NumChars] <string>] [[-EndPosition || End] <string>] [[-DoNotTrim || Trim] <bool>]
function Get-TrimThenSubStr
{
    # SYNTAX: Get-TrimThenSubStr || Get-TrimThenSubStr [-InputString || Input] <string> [-StartPosition || Start] <string> [[-NumberOfCharacters || NumChars] <string>] [[-EndPosition || End] <string>] [[-DoNotTrim || Trim] <bool>]

    <#
        .SYNOPSIS
            Get-TrimThenSubStr will accept an "InputString" and return a substring based on the user-entered parameters: "StartPosition", "NumberOfCharacters", and "EndPosition".

            This function accepts both the "EndPosition" and "NumberOfCharacters" as parameters but only one is necessary to function.

            This function also accepts a boolean, "DoNotTrim" if you do not want the "InputString" trimmed for extraneous whitespace at the start and end of the string. It defaults to a false value

            See the DESCRIPTION in "Get-Help Get-TrimThenSubStr" for greater detail
            See detailed PARAMETER information in "Get-Help Get-TrimThenSubStr -Parameters *"

        .DESCRIPTION
            Get-TrimThenSubStr will accept an "InputString" and return a substring based on the user-entered parameters: "StartPosition", "NumberOfCharacters", and "EndPosition".

            This function accepts both the "EndPosition" and "NumberOfCharacters" as parameters but only one is necessary to function.

            This function also accepts a boolean, "DoNotTrim" if you do not want the "InputString" trimmed for extraneous whitespace at the start and end of the string. It defaults to a false value
            ------------------------------------------------
            "StartPosition", "NumberOfCharacters", and "EndPosition" will accept arithmetic expressions (e.g. 3+2; 5-4)

            This function accepts both the "EndPosition" and "NumberOfCharacters" as parameters but only one is necessary to function.

            If both the "EndPosition" and "NumberOfCharacters" is specified, "NumberOfCharacters" will be used by default if within the range of the "StartPosition" and the length of the string. If "NumberOfCharacters" is outside those bound and "EndPosition" is also specificed, "EndPOsition" will be used. If "EndPosition" is not provided or outside the bounds, the "NumberOfCharacters" will be changed to either the "StartPosition" (1 character) or the length of the string depending which side "NumberOfCharacters" is out of bounds.

            If "StartPosition" is not a number or if either "NumberOfCharacters" or "EndPosition" is not a number, the function will return the "InputString".
            ------------------------------------------------
            See detailed PARAMETER information in "Get-Help Get-TrimThenSubStr -Parameters *"
    #>

    [CmdletBinding(DefaultParameterSetName="First")]
    param 
    (
        # Enter string 
        [Parameter(Mandatory=$true,position=0,ParameterSetName="First")]
        [Parameter(Mandatory=$true,position=0,ParameterSetName="Second")]
            [Alias("Input")][string]$InputString,
        # Enter the start position of the substring
        [Parameter(Mandatory=$true,position=1,ParameterSetName="First")]
        [Parameter(Mandatory=$true,position=1,ParameterSetName="Second")]
            [Alias("Start")][string]$StartPosition,
        # (Preferred) Enter the number of characters from the start of the substring
        [Parameter(Mandatory=$false,position=2,ParameterSetName="First")]
        [Parameter(Mandatory=$false,position=2,ParameterSetName="Second")]
            [Alias("NumChars")][string]$NumberOfCharacters,
        # (Alternative) Enter the end position (within the input string) within the input string
        [Parameter(Mandatory=$false,position=3,ParameterSetName="First")]
        [Parameter(Mandatory=$false,position=3,ParameterSetName="Second")]
            [Alias("End")][string]$EndPosition,
        # (Optional) Enter $true/$false as whether to trim input string whitespace before extracting the substring
        # Default: $false
        [Parameter(Mandatory=$false,position=4,ParameterSetName="First")]
        [Parameter(Mandatory=$false,position=4,ParameterSetName="Second")]
            [Alias("Trim")][bool]$DoNotTrim=$false
    )

    $input=$InputString
    $start=$StartPosition
    $end=$EndPosition
    $chars=$NumberOfCharacters
    [int32]$stringLen=$input.Length
    

    
    if (!($start -match "^[\d\.]+$"))
        {$start=(Invoke-Expression "$start")}
    if (!($end -match "^[\d\.]+$") -and $end -ne "")
        {$end=(Invoke-Expression "$end")}
    if (!($echarsnd -match "^[\d\.]+$") -and $chars -ne "")
        {$chars=(Invoke-Expression "$chars")}

    $start=$start -as [int32]
    $end=$end -as [int32]
    $chars=$chars -as [int32]

    # If $start is not a number or ($end is not a number and $char is empty or not a number) ==> return $inputString
    # IF $start ![0-9] OR ($end ![0-9]  AND ($chars IsEmpty OR $chars ![0-9] ))) return $inputString
    if (!($start -match '^[0-9]+$') -or (!($end -match '^[0-9]+$') -and ($chars -eq "" -or !($chars -match '^[0-9]+$'))))
    {
        return $input
    }

    if ($chars -match '^[0-9]+$' -and $end -match '^[0-9]+$')
    {
        # If $chars is out of bounds AND $end is within bounds, use $end (bounds: $start - $stringLen)
        # (!(1 <= $chars <= $stringLen) AND ($start <= $end <= $stringLen)) ==> ($chars=$end-$start+1)
        if ((($start+$chars -gt $stringLen) -or ($start+$chars -lt 1)) -and ($end -le $stringLen) -and ($end -ge $start)) 
            {$chars=$end-$start+1}
        elseif ($start+$chars -gt $stringLen) {$chars=$stringLen-$start}
        elseif ($start+$chars -lt 1) {$chars=1}
    }
    # If $char is out of bounds, correct to end of string or start of string depending on which side is out of bounds
    elseif ($chars -match '^[0-9]+$' -and !($end -match '^[0-9]+$'))
    {
        if ($start+$chars -gt $stringLen) {$chars=$stringLen-$start}
        elseif ($start+$chars -lt 1) {$chars=1}
    }

    # IF $chars is a number, $end is irrelevant. (if $chars was out of bounds, it was corrected above with $end considered if existent)
    # If $chars is empty or not a number (AND $end is a number), ensure $end is within bounds; if not, correct to $start or $stringLen
    if ($chars -eq "" -or !($chars -match '^[0-9]+$'))
    {
        if ($end -gt $stringLen) {$end=$stringLen}
        if ($end -lt $start) {$end=$start+1}
        $chars=$end-$start
    }    

    if ($DoNotTrim){return "$input".Substring($start,$chars)}
    else {return "$input".Trim().Substring($start,$chars)}
}

function New-UniqueSequentialFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][String]$NewFolderBaseName,
        [Parameter(Mandatory=$false)][int32]$AppendedNumberTotalDigits=4,
        [Parameter(Mandatory=$false)][int32]$StartNumber=1,
        [Parameter(Mandatory=$false)][bool]$ForceNumbering=$false
    )

    begin
    { 
        #region     Global Variable & Shortened Parameter Variable Names

        # Parameter Variables
        [string]$base=$NewFolderBaseName
        $leading=$AppendedNumberTotalDigits
        $start=$StartNumber
        $force=$ForceNumbering

        $uniqueFolderBaseName="Unique Folder Base"
        $forceUniqueFolder=$false
        $isValidUNCRoot=$false
        $isWinDriveRoot=$false
        $baseIsOnlyUNCroot=$false
        $uncRootPath=""

        #endregion  Global Variable & Shortened Parameter Variable Names

        #region     Embedded Functions

        # "Variables" that may change throughout script.
        # Functions are used to accomplish this task
        function BaseLen {return "$base".trim().Length}      
        function BaseLenIsInclusiveOf
        {
            [CmdletBinding()]
            param
            (
                [Parameter()]$low=2147483648,
                [Parameter()]$high=2147483647
            )

            if ($low -eq "-"){$low=-2147483648 -as [int32]}
            if ($high -eq "+"){$high=2147483647 -as [int32]}

            $baseLength=(BaseLen)
            if ($baseLength -ge $low -and $baseLength -le $high) {return $true} else {return $false}
        }

        function BaseLeading_. {if ((BaseLenIsInclusiveOf 0 0)) {return $false} else {return (Get-TrimThenSubStr "$base" 0 1) -eq "."}}
        function BaseLeading_\ {if ((BaseLenIsInclusiveOf 0 0)) {return $false} else {return (Get-TrimThenSubStr "$base" 0 1) -eq "\"}}
        function BaseLeading_\. {if ((BaseLenIsInclusiveOf 0 0)) {return $false} else {return (Get-TrimThenSubStr "$base" 0 2) -eq "\."}}
        function baseSubStr_0_LenMinus1 {if ((BaseLenIsInclusiveOf 0 0)){return "$base"} else {return Get-TrimThenSubStr "$base" 0 ((BaseLen)-1)}}            
        function BaseLeading_\\ {if ((BaseLenIsInclusiveOf 0 1)){return $false} else {return (Get-TrimThenSubStr "$base" 0 2) -eq "\\"}}
        #function baseSubStr_1_2 {if ((BaseLenIsInclusiveOf 0 2)){return $base} else{return Get-TrimThenSubStr $base 1 2}}
        function Base2ndChar_: {if ((BaseLenIsInclusiveOf 0 1)) {return $false} else {return (Get-TrimThenSubStr "$base" 1 1) -eq ":"}}
        function Base2ndChar_\ {if ((BaseLenIsInclusiveOf 0 1)) {return $false} else {return (Get-TrimThenSubStr "$base" 1 1) -eq "\"}}
        #function baseSubStr_1_2_Is:_:\ {if ((BaseLenIsInclusiveOf 0 2)){return $false} else {return (Get-TrimThenSubStr $base 1 2) -eq ":\"}}
        function Base2nd3rdChar_.\ {if ((BaseLenIsInclusiveOf 0 2)){return $false} else {return (Get-TrimThenSubStr "$base" 1 2) -eq ".\"}}
        #function baseSubStr_1_LenMinus1 {if ((BaseLenIsInclusiveOf 0 1)){return $base} else {return Get-TrimThenSubStr $base 1 ((BaseLen)-1)}}
        #function baseSubStr_LenMinus1_1 {if ((BaseLenIsInclusiveOf 0 0)){return $base} else {return Get-TrimThenSubStr $base ((BaseLen)-1) 1}}
        function BasePathExists {return (Test-Path -Path "$base")}
        function BasePathIsValid {return (Test-Path "$base" -IsValid)}


        #endregion  Embedded Functions  

        # Test if $NewFolderBaseName passed by user is in a valid format. If not, insert generic $NewFolderBaseName in current directory
        #Test-Path -Path $NewFolderBaseName



        # Reformat UNC

        if ((BaseLeading_\\) -and !(BasePathExists))
        {
            $base=".\"
        }
        elseif ((BaseLeading_\\) -and (BasePathExists))
        {            
            $isValidUNCRoot=$true
            
            $uncServer=("$base" -split "\\")[2]
            $uncShare=("$base" -split "\\")[3]

            $uncRootPath="\\$uncServer\$uncShare"

            $counter=0
            foreach ($i in ("$base" -split "\\"))
            {
                if ($counter -le 3){}
                elseif ($counter -eq 4)
                {
                    $uncFolder+=$i
                }
                else 
                {
                    $uncFolder+="\"+$i
                }    
                $counter++
            }

            if ("$uncFolder" -eq "")
            {
                $baseIsOnlyUNCroot=$true
            }
        }

        # Determine if $base is a Windows drive root only (e.g. "c:\"; "c:"; "\" -- NOT "c:\<something more>")

        $isWinDriveRoot=Path::IsPathRooted($base)

        # Test if $base folder can be created. In not, $base=".\"
        if ($isValidUNCRoot -or !(BaseLeading_\\))
        {
            if (!(Test-FolderCanBeCreated "$base"))
            {
                $base=".\"
            }
        }

        # $base is current path (.\ OR .) or is invalid format --> $base=".\UniquePath"
        if ((BasePathExists))
        {
            if ($isValidUNCRoot -and $baseIsOnlyUNCroot) 
            {
                $forceUniqueFolder=$true
            }
            elseif ($isValidUNCRoot -and !$baseIsOnlyUNCroot) 
            {
                # Do nothing
            }
            elseif ("$base" -eq '.\' -or "$base" -eq '.' -or !(BasePathIsValid)) 
            {
                $forceUniqueFolder=$true
                $base=(Resolve-Path .\)
            }    
            elseif (BaseLeading_\. -and (BaseLenIsInclusiveOf 0 2))
            {
                $isRoot=$true
                $forceUniqueFolder=$true
                $base=(Resolve-Path ((Get-Location).Drive.root)).path
                echo "$base"
            }
            elseif ("$base" -eq '\')
            {
                $forceUniqueFolder=$true
                $base=(Resolve-Path -Path "$base").Path
            }  
            # If $base exists and is root drive notated "[a-z]:\"", resolve full path
            elseif ((BasePathExists) -and ((BaseLenIsInclusiveOf 2 3) -and (Base2ndChar_:)))
            {
                echo "Asf"
                $isRoot=$true
                $forceUniqueFolder=$true
                $base=(Resolve-Path -Path "$base").Path
            }
            # If $base exists and is NOT root drive", resolve full path        
            elseif ((BasePathExists) -and (BaseLenIsInclusiveOf 4 +) -and (Base2ndChar_:))
            {
                $base=(Resolve-Path -Path "$base").Path
            }
        }
        # If $base doesn't exist AND ...
        elseif (!(BasePathExists))
        { 
            # AND ... check if it is relative       
            if ((BaseLeading_.) -and ((Base2ndChar_\) -or (Base2nd3rdChar_.\)))
            {
                $base=(Join-Path ((Resolve-Path .\).path) -ChildPath "$base")
            }
            elseif ((Base2ndChar_:) -and (BaseLenIsInclusiveOf 2 3))
            {
                $forceUniqueFolder=$true
                $base=(Resolve-Path -path ".\")
            }
            elseif ((BaseLeading_\) -and !(BaseLeading_\\))
            {
                echo "wfas"
                $base=([system.io.path]::getfullpath(("$base")))
            }
            elseif ((BaseLeading_\\) -and $isValidUNCRoot -and !($baseIsOnlyUNCroot))
            {
                $isValidUNC=$true
                $base=(Join-Path "$uncRootPath" -ChildPath "$uncFolder")
            }
            else
            {
                #$base=(Join-Path -path (Resolve-Path -Path ".\") -ChildPath "$base")
                $base="$base"
            }
        }

        if (!($isValidUNC))
        {
            $base=[system.io.path]::getfullpath(("$base"))
        }
        # echo "bv" (BasePathExists)  
        # $base=($base.trim().Substring(0,$base.Trim().Length-1))
        # echo "bv" (BasePathExists)       
        # If path does NOT exist, check if root 
        # Determine if $base includes a trailing '\' and if so, remove
        #[bool]$hasTrailingBackslash

        if (!($isRoot))
        {
            $base="$base".TrimEnd('\')
        }
    }

    process
    {
        if (!(BasePathExists) -and $force -eq $false) {return "$base".TrimEnd('\')}

        if ((BasePathExists) -and $forceUniqueFolder)
        {
            $base=(Join-Path "$base" -ChildPath "$uniqueFolderBaseName")
        }

        if (!(BasePathExists) -and $force -eq $true)
        {
            $formattedCounter=("{0:d$leading}" -f $start)
            return "$("$base".trimend('\')) $formattedCounter"
        }

        if ((BasePathExists))
        {    
            if (!(BasePathExists)) {return "$base".trimend('\')}
            else 
            {
                $folderExists=$true
                while ($folderExists)
                {
                    $formattedCounter=("{0:d$leading}" -f $start)
                    $newPath="$base $formattedCounter"
                    if (Test-Path -Path "$newPath") {$start++; continue}
                    elseif (!(Test-Path -Path "$newPath"))
                    {
                        $folderExists=$false
                        return "$($newPath.trimend('\'))"
                    }
                }
            }
        }
        return "$base".trimend('\')
    }

    End
    {

    }



        # # No longer applicable
        # #region First character '\'; Transform to Windows format
        # if ((baseSubStr_0_1) -eq '\' -and (BaseLen) -eq 1)
        # {
        #     Write-Output "2"
        #     $base=(Get-Location).Drive.Name+"`:\"
        # } 
        # elseif ((baseSubStr_0_1) -eq '\' -and (BaseLen) -gt 1)
        # {
        #     Write-Output "2"
        #     $base=(Get-Location).Drive.Name+"`:\"+(baseSubStr_1_LenMinus1)
        # }

        # #endregion First character '\'; Transform to Windows format

}

