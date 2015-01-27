$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath


$apiKey = 'xxxxxxxxxxxxxxxxxxxxxxxxxxx'

(ls *.nupkg) | foreach-object {
	write-host $_
    .\tools\nuget push $_ $apiKey -Source https://www.myget.org/F/codescape/api/v2/package
}
