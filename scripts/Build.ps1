Framework "4.0"

properties {
    $baseDir = resolve-path ..\
    $solutionName = "SOLUTION_NAME"
	$nuget = "$baseDir\tools\NuGet.exe"

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
    exec { & $nuget restore $baseDir\$solutionName }
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

## Define modules with extra tasks here
$addedTasks = "package", "tests"

$addedTasks | foreach-object {
    Import-Module  (join-path "." "$_.psm1" )
}

function stop_iis_express() {
    if (Get-Process iisexpress -ErrorAction silentlycontinue) {
		Stop-Process -processname iisexpress
	}
}

function global:delete_file($file) {
    if($file) { remove-item $file -force -ErrorAction SilentlyContinue | out-null } 
}
 