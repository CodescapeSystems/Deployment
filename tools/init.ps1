param($installPath, $toolsPath, $package, $project)


write-host "pkg: " $package
write-host "install path" $installPath
write-host "tools path " $toolsPath

#INSTALL PSAKE
#$psakeModule = Join-Path $toolsPath 'psake/psake.psm1'
#import-module $psakeModule

$solutionNode = Get-Interface $dte.Solution ([EnvDTE80.Solution2])


$solutionName = split-path $solutionNode.FullName -leaf
write-host "solution name: " $solutionName

$rootDir = (Get-Item $installPath).parent.parent.fullname
$deployTarget = "$rootDir\deploy\"
$toolsTarget = "$rootDir\tools\"

if (!(test-path $deployTarget)) {
    mkdir $deployTarget
}

if (!(test-path $toolsTarget)) {
    mkdir $toolsTarget
}


## get location of scripts
$scriptsSource = join-path $installPath 'scripts\'

## copy scripts into local
Copy-Item -Path ($scriptsSource + '*')  -Destination $deployTarget

## copy tools (nuget and psake) into local
Copy-Item -Recurse -Path ($toolsPath + '\*')  -Destination $toolsTarget

delete_file($toolsTarget + '\init.ps1')


## Replace the solution name in the build file

$replaceFile = $scriptsSource + 'build.ps1'
$outFile = $deployTarget + 'build.ps1'

replaceInFile $replaceFile  $outFile "SOLUTION_NAME" "$solutionName"


## Add the items to our solution

$deployFolder = $solutionNode.Projects | where-object { $_.ProjectName -eq "Deployment" } | select -first 1
if(!$deployFolder) {
    $deployFolder = $solutionNode.AddSolutionFolder("deployment")
}

$folderItems = Get-Interface $deployFolder.ProjectItems ([EnvDTE.ProjectItems])
    
(ls $deployTarget -exclude "*.cmd", "*.exe") | foreach-object {
    $folderItems.AddFromFile($_.FullName)
}

(ls $toolsTarget -exclude "*.cmd", "*.exe") | foreach-object {
        $folderItems.AddFromFile($_.FullName)
}


function replaceInFile($file, $dest, $find, $replace) {
    write-host "Find: " $find
    write-host "Replace: " $replace

    if ((test-path $file)) {
        (gc $file) -replace($find, $replace) | sc $dest
    }
}


function delete_file($file) {
    if($file) { remove-item $file -force -ErrorAction SilentlyContinue | out-null } 
}