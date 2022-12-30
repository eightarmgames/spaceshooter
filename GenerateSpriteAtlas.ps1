param (
    [Parameter(Mandatory=$true)][string]$inputFile,
    [string]$project = "EightArmGames.SpaceShooter",
    [switch]$Force
)

$inputFile = Join-Path -Path $PSScriptRoot -ChildPath "$inputFile"
$input = Get-Item $inputFile
$inputFileName = $input.Name
$inputBaseName = $input.BaseName

$spriteAtlasRootPath = Join-Path -Path $PSScriptRoot -ChildPath "SpriteAtlasRoot"
$spriteAtlasOutputPath = Join-Path -Path $PSScriptRoot -ChildPath "$project/Content"

$buildCacheFile = Join-Path -Path $spriteAtlasOutputPath -ChildPath "$inputBaseName.cache"
if (Test-Path -Path $buildCacheFile) {
    $svgDt = $input.LastWriteTime
    $cacheDt = [DateTime](Get-Content $buildCacheFile)
    
    if (-Not $Force) {
        if ($svgDt -lt $cacheDt) {
            Write-Host "Atlas has been generated since the most recent update to $inputFileName";
            Write-Host "Aborting."
            exit
        }
    }
}

if (Test-Path -Path $spriteAtlasRootPath) {
    Remove-Item -Recurse -Force $spriteAtlasRootPath
}
Write-Host "Creating Sprite Atlas root folder ... "
New-Item -Type Directory $spriteAtlasRootPath | Out-Null

if (-Not(Test-Path -Path $spriteAtlasOutputPath)) {
    Write-Host "Creating Sprite Atlas output folder ..."
    New-Item -Type Directory $spriteAtlasOutputPath | Out-Null
}

inkscape --query-all $inputFile | foreach {
    $id = $_.Split(',')[0]
    if ($id.StartsWith('sprite-')) {
        $exportFile = Join-Path -Path $spriteAtlasRootPath -ChildPath "$id.png"
        Write-Host "Exporting $id from $inputFile ... "
        inkscape --export-type="png" `
                 --export-filename="$exportFile" `
                 --export-id="$id" `
                 $inputFile
    }
    if ($id.StartsWith('anim-')) {
        $parts = $id.Split("-")
        if ($parts.Length -ne 3) {
            throw "Error: Animation sprite must be named anim-{name}-{frameNumber}. Name cannot contain '-'."
        }

        $exportPath = Join-Path -Path $spriteAtlasRootPath -ChildPath $parts[1]
        if (-Not(Test-Path -Path $exportPath)) {
            Write-Host "Creating Animation folder" $parts[1] "... "
            New-Item -Type Directory $exportPath | Out-Null
        }

        $exportFile = Join-Path -Path $exportPath -ChildPath "$id.png"
        Write-Host "Exporting $id from $inputFileName ... "
        inkscape --export-type="png" `
                 --export-filename="$exportFile" `
                 --export-id="$id" `
                 $inputFile
    }
}

$spriteAtlasImageFile = Join-Path -Path $spriteAtlasOutputPath -ChildPath "$inputBaseName.png"
$spriteAtlasMapFile = Join-Path -Path $spriteAtlasOutputPath -ChildPath "$inputBaseName.atlas"

SpriteAtlasPacker `
    -image:$spriteAtlasImageFile `
    -map:$spriteAtlasMapFile `
    $spriteAtlasRootPath

Get-Date | Set-Content $buildCacheFile