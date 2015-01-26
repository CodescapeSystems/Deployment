param($installPath, $toolsPath, $package, $project)


#Function defs
function delete_file($file) {
    if($file) { remove-item $file -force -ErrorAction SilentlyContinue | out-null } 
}



write-host "pkg: " $package
write-host "install path" $installPath
write-host "tools path " $toolsPath

$solutionNode = Get-Interface $dte.Solution ([EnvDTE80.Solution2])


$solutionName = split-path $solutionNode.FullName -leaf
write-host "solution name: " $solutionName

$rootDir = (Get-Item $installPath).parent.parent.fullname
$deployTarget = "$rootDir\deploy\"
$toolsTarget = "$rootDir\tools\"


$deployFolder = $solutionNode.Projects | where-object { $_.ProjectName -eq "Deployment" } | select -first 1
if($deployFolder) {
    $solutionNode.Remove($deployFolder)
}


if (test-path $deployTarget) {
     Remove-Item .\foldertodelete -Force -Recurse
}

if (test-path $toolsTarget) {
    Remove-Item .\toolsTarget -Force -Recurse
}