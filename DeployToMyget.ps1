$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath


$apiKey = 'c1c44355-0d25-4e56-8e99-4374451785ab'

(ls *.nupkg) | foreach-object {
	write-host $_
    .\nuget push $_ $apiKey -Source https://www.myget.org/F/codescape/api/v2/package
}
