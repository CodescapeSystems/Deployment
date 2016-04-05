$baseDir = resolve-path ../
$nuget = "$baseDir\tools\NuGet.exe"

task CreateNugetPackages -depends UnitTest {
    Write-Host "Creating NuGet packages"

    $packageOutput =  "$baseDir\NugetPackages"

    if(-Not (test-path $packageOutput)) {
        mkdir $packageOutput
    }

    foreach ($file in get-ChildItem -Path $baseDir -Include *.nuspec -Exclude docs.nuspec -Recurse) {
        Write-Host $file.Name
        exec { & $nuget pack $file.FullName -Properties Configuration=Release -OutputDirectory $packageOutput -version $global:packageversion}
  }
}