$baseDir = resolve-path ..\

$nuget = "$baseDir\tools\NuGet.exe"
$nunit = "$baseDir\packages\NUnit.Runners.2.6.4\tools\nunit-console.exe"

task CleanResults {
    write-host "Clean Results"
    delete_file $baseDir\UnitTestResult.xml
	  delete_file $baseDir\IntegrationTestResult.xml

    write-host "Installing nunit runners"
    & $nuget Install NUnit.Runners -version 2.6.4 -SolutionDirectory $baseDir
}

task UnitTest -depends Compile, CleanResults {
    write-host "Unit tests"
    exec { & $nunit  $baseDir\Project.UnitTests\bin\Debug\Project.UnitTests.dll /result=$baseDir\UnitTestResult.xml }
}

task IntegrationTest -depends Compile, CleanResults {
    write-host "Integration Tests"
    exec { & $nunit  $baseDir\Project.IntegrationTests\bin\Debug\Project.IntegrationTests.dll /result=$baseDir\IntegrationTestResult.xml }
}
