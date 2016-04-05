####  THIS SECTION DETAILS PACKAGING - INCLUDES EXAMPLE OF PACKAGING A WEB PROJECT  ####
$baseDir = resolve-path ../

task Package -depends UnitTest {
    write-host "Package"

#   Other useful msbuild switches: 
#   /p:RunOctoPack=true   - if octo pack is installed this will package the project
#   /p:OctoPackPackageVersion=$global:version   - to override package version

#    exec { msbuild  $baseDir\[PATH TO WEB PROJECT].csproj /t:package  /p:Configuration=Release }
#    exec { msbuild  $baseDir\[PATH TO WEB PROJECT 2].csproj /t:package /p:Configuration=Release }

}

