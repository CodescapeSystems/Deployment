####  THIS SECTION DETAILS PACKAGING - INCLUDES EXAMPLE OF PACKAGING A WEB PROJECT  ####
task Package -depends UnitTest {
    write-host "Package"
#    exec { msbuild  $baseDir\[PATH TO WEB PROJECT].csproj /t:package /p:RunOctoPack=true /p:Configuration=Release }

#    exec { msbuild  $baseDir\[PATH TO WEB PROJECT 2].csproj /t:package /p:RunOctoPack=true /p:Configuration=Release }
}

