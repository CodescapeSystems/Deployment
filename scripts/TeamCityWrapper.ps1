param (
	[string]$task = "",
	[string]$version = "1.0.0.0",
	[string]$packageversion = ""
)

Try
{
	Import-Module '..\packages\PSAKE_LOCATION\psake.psm1'
	Invoke-psake '.\Build.ps1' -task $task -parameters @{version=$version;packageversion=$packageversion} 

	$baseDir = resolve-path ..\
	if (Test-Path $baseDir\UnitTestResult.xml) {
		write-host "##teamcity[importData type='nunit' path='$baseDir\UnitTestResult.xml']"
	}
	if (Test-Path $baseDir\IntegrationTestResult.xml) {
		write-host "##teamcity[importData type='nunit' path='$baseDir\IntegrationTestResult.xml']"
	}

	if ($lastexitcode) { 
		write-host "ERROR: $lastexitcode" -fore RED
		write-host "##teamcity[buildStatus status='FAILURE']"
		exit $lastexitcode 
	}
}
Catch [system.exception]
{
	write-host "##teamcity[buildStatus status='FAILURE']"
}

if ($psake.build_success -eq $false) 
{ 
	write-host "##teamcity[buildStatus status='FAILURE']"
	exit 1 
} 
else 
{ exit 0 }