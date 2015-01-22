param(
    [int]$buildNumber = 0
    )

if(Test-Path Env:\APPVEYOR_BUILD_NUMBER){
    $buildNumber = [int]$Env:APPVEYOR_BUILD_NUMBER
    Write-Host "Using APPVEYOR_BUILD_NUMBER"
}

"Build number $buildNumber"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

$destDir = "$dir\bin"
if (Test-Path $destDir -PathType container) {
    Remove-Item $destDir -Recurse -Force
}

Copy-Item -Recurse $dir\nuget $destDir
Copy-Item -Recurse $dir\tools $destDir\tools

.\nuget pack "$destDir\package.nuspec" -Verbosity quiet



Copy-Item *.nupkg package.zip