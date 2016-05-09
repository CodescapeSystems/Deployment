$baseDir = resolve-path ..\

$nuget = "$baseDir\tools\NuGet.exe"
$nunit = "$baseDir\packages\NUnit.ConsoleRunner.3.2.1\tools\nunit3-console.exe"

task CleanResults {
    write-host "Clean Results"
    delete_file $baseDir\UnitTestResult.xml
	  delete_file $baseDir\IntegrationTestResult.xml

    write-host "Installing nunit runners"
    & $nuget Install NUnit.Runners -version 3.2.1 -SolutionDirectory $baseDir
}

task UnitTest -depends Compile, CleanResults {
    write-host "Unit tests"
    exec { & $nunit  $baseDir\UNITTEST_PROJECT\bin\Debug\UNITTEST_PROJECT.dll /result=$baseDir\UnitTestResult.xml }
}

task IntegrationTest -depends Compile, CleanResults {
    write-host "Integration Tests"
    exec { & $nunit  $baseDir\INTTEST_PROJECT\bin\Debug\INTTEST_PROJECT.dll /result=$baseDir\IntegrationTestResult.xml }
}