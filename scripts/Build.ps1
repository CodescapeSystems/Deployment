Framework "4.0"

properties {
    $baseDir = resolve-path ..\
    $solutionName = "SOLUTION_NAME"
	  $nuget = "$baseDir\tools\NuGet.exe"
	  
    
    # $nunit = "$baseDir\nunit-console.exe"

    if(!$version)
    {
        $version = "1.0.0.0"
    }

    Write-Host "Generating version $version"
}

task default -depends Package

task Init {
    Write-Host "Clean test results"
	  delete_file $baseDir\UnitTestResult.xml
	  delete_file $baseDir\IntegrationTestResult.xml
}

task RestorePackages -depends Init {
    Write-Host "Restoring NuGet packages"
    exec { & $nuget restore $solutionName }
}

task Compile -depends RestorePackages {
    Write-Host "Build Debug"
    Write-Host "Cleaning the solution $solutionName"
    exec { msbuild /t:clean /v:q /nologo /p:Configuration=Debug $baseDir\$solutionName }
    Write-Host "Building the solution"
    exec { msbuild /t:build /v:q /nologo /p:Configuration=Debug $baseDir\$solutionName }

    Write-Host "Build Release"
    Write-Host "Cleaning the solution $solutionName"
    exec { msbuild /t:clean /v:q /nologo /p:Configuration=Release $baseDir\$solutionName }
    Write-Host "Building the solution"
    exec { msbuild /t:build /v:q /nologo /p:Configuration=Release $baseDir\$solutionName }
}

task UnitTest -depends Compile {
    exec { & $nunit  $baseDir\Bcs.Imis.UnitTests\bin\Debug\Bcs.Imis.UnitTests.dll /result=$baseDir\UnitTestResult.xml }
}

task Package -depends UnitTest {
    exec { msbuild  $baseDir\Bcs.Imis\Bcs.Imis.csproj /t:package /p:RunOctoPack=true /p:Configuration=Release }
    exec { msbuild  $baseDir\Bcs.ImisAdministration\Bcs.ImisAdministration.csproj /t:package /p:RunOctoPack=true /p:Configuration=Release }
}

task IntegrationTest -depends Init {
    exec { & $nunit  $baseDir\Bcs.Imis.IntegrationTests\bin\Debug\Bcs.Imis.IntegrationTests.dll /result=$baseDir\IntegrationTestResult.xml }
}

function stop_iis_express() {
    if (Get-Process iisexpress -ErrorAction silentlycontinue) {
		Stop-Process -processname iisexpress
	}
}

function global:delete_file($file) {
    if($file) { remove-item $file -force -ErrorAction SilentlyContinue | out-null } 
}
 