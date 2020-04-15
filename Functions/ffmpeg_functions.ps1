function ffmpeg_TrimFrameExactly_ReturnFile
{
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)][Alias("Source","Src")][string]$SourceFile,
        [Parameter(mandatory=$true)][Alias("Container","Cntr")][string]$OutputContainer,
        [Parameter(mandatory=$true)][Alias("Destination","Dstn")][string]$DestinationPath,
        [Parameter(mandatory=$true)][Alias("OutputFileNoExt","OutFileNoExt")][string]$OutpuFileNoExtension,
        [Parameter(mandatory=$true)][Alias("StartF","StrtF","SFrm","SF","StrtFrm")][string]$StartFrame,
        [Parameter(mandatory=$true)][Alias("EndF","EFrm","EF","EndFrm")][string]$EndFrame,
        [Parameter(mandatory=$true)][Alias("StartT","StrtT","STm","ST","StrtTm")][string]$StartTime,
        [Parameter(mandatory=$true)][Alias("EndT","EnT","ETm","ET","EnTm")][string]$EndTime,
    )
    Write-Output $SourceFile $DestinationPath
}

function ffmpeg_TrimFrameKeyFrameMargins_ReturnFile
{}

function ffmpeg_ConcatenateClips_ReturnFile
{}

function ffmpeg_Encode_ReturnFile
{}

