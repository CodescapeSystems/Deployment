Framework "4.0"

properties {
    $baseDir = resolve-path ..\
    $solutionName = "testSolution.sln"
	  $nuget = "$baseDir\tools\NuGet.exe"

    if(!$version)
    {
        $version = "1.0.0.0"
    }

    Write-Host "Generating version $version"
}

task default -depends BaseBuild

task BaseBuild -depends Compile {
    Write-Host "Base Build"
    Reset-AssemblyInfoFiles($baseDir)
}

task Init {
    Write-Host "Initialising"
	Reset-AssemblyInfoFiles($baseDir)
}

task RestorePackages {
    Write-Host "Restoring NuGet packages"
    exec { & $nuget restore $baseDir\$solutionName }
}

task PatchAssemblyInfo {
    Write-Host "Patching AssemblyInfo"
    Update-AssemblyInfoFiles $version $baseDir
}

task Compile -depends RestorePackages, PatchAssemblyInfo {
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
 

function Update-AssemblyInfoFiles ([string] $version, [string] $executingDir, [System.Array] $excludes = $null, $make_writeable = $false) {
 
#-------------------------------------------------------------------------------
# Update version numbers of AssemblyInfo.cs
# adapted from: http://www.luisrocha.net/2009/11/setting-assembly-version-with-windows.html
#-------------------------------------------------------------------------------
 
    if ($version -notmatch "[0-9]+(\.([0-9]+|\*)){1,3}") {
        Write-Error "Version number incorrect format: $version"
    }
    $versionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $versionAssembly = 'AssemblyVersion("' + $version + '")';
    $versionFilePattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $versionAssemblyFile = 'AssemblyFileVersion("' + $version + '")';

    Get-ChildItem $executingDir -r -filter AssemblyInfo.cs | % {
        $filename = $_.fullname
        $update_assembly_and_file = $true
        # set an exclude flag where only AssemblyFileVersion is set
        if ($excludes -ne $null)
        { $excludes | % { if ($filename -match $_) { $update_assembly_and_file = $false	} } }
 
        # We are using a source control (TFS) that requires to check-out files before
        # modifying them. We don't want checkins so we'll just toggle
        # the file as writeable/readable
        if ($make_writable) { Writeable-AssemblyInfoFile($filename) }
     
        # see http://stackoverflow.com/questions/3057673/powershell-locking-file
        # I am getting really funky locking issues.
        # The code block below should be:
        # (get-content $filename) | % {$_ -replace $versionPattern, $version } | set-content $filename
         
        $tmp = ($file + ".tmp")
        if (test-path ($tmp)) { remove-item $tmp }
     
        if ($update_assembly_and_file) {
            (get-content $filename) | % {$_ -replace $versionFilePattern, $versionAssemblyFile } | % {$_ -replace $versionPattern, $versionAssembly } > $tmp
            write-host Updating file AssemblyInfo and AssemblyFileInfo: $filename --> $versionAssembly / $versionAssemblyFile
        } else {
            (get-content $filename) | % {$_ -replace $versionFilePattern, $versionAssemblyFile } > $tmp
            write-host Updating file AssemblyInfo only: $filename --> $versionAssemblyFile
        }
         
        if (test-path ($filename)) { remove-item $filename }
        move-item $tmp $filename -force
     
        if ($make_writable) { ReadOnly-AssemblyInfoFile($filename) }
     
    }
}

function Reset-AssemblyInfoFiles([string] $dir){
    Update-AssemblyInfoFiles "1.0.0.0" $dir
}
