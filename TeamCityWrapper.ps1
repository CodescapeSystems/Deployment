param (
	[string]$task = "",
	[string]$version = "1.0.0.0"
)

Try
{
	Import-Module '.\packages\psake.4.3.2\tools\psake.psm1'
	Invoke-psake '.\Build.ps1' -task $task -parameters @{version=$version} 

	$baseDir = resolve-path .\
	if (Test-Path $baseDir\UnitTestResult.xml) {
		write-host "##teamcity[importData type='nunit' path='$baseDir\UnitTestResult.xml']"
	}
	if (Test-Path $baseDir\IntegrationTestResult.xml) {
		write-host "##teamcity[importData type='nunit' path='$baseDir\IntegrationTestResult.xml']"
	}
	if (Test-Path $baseDir\CardsSpecificationTestResult.xml) {
		write-host "##teamcity[importData type='nunit' path='$baseDir\CardsSpecificationTestResult.xml']"
	}
	if (Test-Path $baseDir\FastpaySpecificationTestResult.xml) {
		write-host "##teamcity[importData type='nunit' path='$baseDir\FastpaySpecificationTestResult.xml']"
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