Framework "4.6"

# Development config
$global:devConfig = ""
# Global version shared to all tasks
$global:version = "1.0.0.0"

# Global package version shared to all tasks
$global:packageversion = "1.0.0.0"

# Global engine used to check if this is runnig on local machine of build server
$global:engine = "server"

## Define modules with extra tasks here
$addedTasks = "package", "tests", "nuget"

properties {
    $baseDir = resolve-path ..\
    $solutionName = "SOLUTION_NAME"
	$nuget = "$baseDir\tools\NuGet.exe"

    if(!$version)
    {
        $global:version = "1.0.0.0"
    }
    else
    {
        $global:version  = $version
    }

    Write-Host "Generating version $version"

    if(!$packageversion)
    {
        $global:packageversion = $global:version
    }
    else
    {
        $global:packageversion  = $packageversion
    }

    Write-Host "Generating package version $packageversion"
}

task default -depends BaseBuild

task LoadConfiguration {
    $configLocation = "$env:UserProfile\developerConfig.json"

    if(test-path $configLocation)
    {
        $global:devConfig = (Get-Content $configLocation) -join "`n" | ConvertFrom-Json
        $global:engine = "local"
        write-host "Hi " $devConfig.user
    }
    else {
        $global:engine = "server"
        write-host "Configuration not loaded, assuming build server"
    }
}

task BaseBuild -depends Compile {
    Write-Host "Base Build"
    Reset-AssemblyInfoFiles($baseDir)
}

task RestorePackages -depends LoadConfiguration {
    Write-Host "Restoring NuGet packages"

    ## Remove this deployment package from config
    ## This is a nasty hack until I can think of a tidier way
    $path = "$baseDir\.nuget\packages.config"
    if(test-path $path) {
        $xml = [xml](Get-Content $path)
        $package = $xml.Packages.Package | where {$_.id -eq 'Codescape.Deployment'}
        
        if($package -ne $null){
            [Void]$package.ParentNode.RemoveChild($package)
            $xml.Save($path)
        }
    }

    if($global:devConfig -eq "") ## No local config loaded
    {
        $config = GetConfig "__config.json"
        write-host "Running Server build from __config.json"
        if($config -ne "" -and $config.packageSources){
		    write-host "Pulling from __config"
            restoreUsingPackages $config.packageSources
        }else{
		    throw "No config file or package sources found!"
	    }
    }
    else{
        if($global:devConfig.packageSources){
            write-host "Running from developer config"
            restoreUsingPackages $global:devConfig.packageSources
        }else{
            write-host "Running from default location"
            exec { & $nuget restore $baseDir\$solutionName }
        }
    }
}

function restoreUsingPackages($sources){
    $nugetSource = $sources -join ';'
    exec { & $nuget restore $baseDir\$solutionName -Source $nugetSource }
}

task PatchAssemblyInfo {
    Write-Host "Patching AssemblyInfo"
    Update-AssemblyInfoFiles $version $baseDir
}

task Compile -depends RestorePackages, PatchAssemblyInfo {
    Write-Host "Build Release"
    Write-Host "Cleaning the solution $solutionName"
    exec { msbuild /t:clean /v:q /nologo /p:Configuration=Release $baseDir\$solutionName }
    Write-Host "Building the solution"
    exec { msbuild /t:build /v:q /nologo /p:Configuration=Release $baseDir\$solutionName }
}

$addedTasks | foreach-object {
    Import-Module  (join-path "." "$_.psm1" )
}

function global:delete_file($file) {
    if($file) { remove-item $file -force -ErrorAction SilentlyContinue | out-null } 
}

function GetConfig([string] $file){
    write-host "Getting config for " $file
    $x = ""

    $configLocation = "$baseDir\deploy\$file"
    if(test-path $configLocation) {
        $x = (Get-Content $file) -join "`n" | ConvertFrom-Json
    }

    write-host "Read information " $x

    return $x
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
