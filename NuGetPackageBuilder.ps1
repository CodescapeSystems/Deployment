param(
    [string]$buildNumber = "1.0.0.0"
    )

"Build number $buildNumber"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

$destDir = "$dir\bin"
if (Test-Path $destDir -PathType container) {
    Remove-Item $destDir -Recurse -Force
}

mkdir $destDir

Copy-Item $dir\nuget\*.nuspec $destDir
Copy-Item $dir\nuget\*.txt $destDir
Copy-Item -Recurse $dir\tools $destDir
Copy-Item -Recurse $dir\scripts $destDir\scripts

.\tools\nuget pack "$destDir\package.nuspec" -version $buildNumber -Verbosity quiet



Copy-Item *.nupkg package.zip
