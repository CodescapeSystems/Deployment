$baseDir = resolve-path ..\

$nunit = "$baseDir\packages\NUnit.Runners.2.6.4\tools\nunit-console.exe"

task CleanResults {
    write-host "Clean Results"
    delete_file $baseDir\UnitTestResult.xml
	  delete_file $baseDir\IntegrationTestResult.xml
}

task UnitTest -depends Compile, CleanResults {
    write-host "Unit tests"
    exec { & $nunit  $baseDir\Project.UnitTests\bin\Debug\Project.UnitTests.dll /result=$baseDir\UnitTestResult.xml }
}

task IntegrationTest -depends Compile, CleanResults {
    write-host "Integration Tests"
    exec { & $nunit  $baseDir\Project.IntegrationTests\bin\Debug\Project.IntegrationTests.dll /result=$baseDir\IntegrationTestResult.xml }
}
