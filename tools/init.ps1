param($installPath, $toolsPath, $package, $project)

#Function defs
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


write-host "pkg: " $package
write-host "install path" $installPath
write-host "tools path " $toolsPath

$solutionNode = Get-Interface $dte.Solution ([EnvDTE80.Solution2])

$solutionName = split-path $solutionNode.FullName -leaf
write-host "solution name: " $solutionName

$rootDir = (Get-Item $installPath).parent.parent.fullname
$deployTarget = "$rootDir\deploy\"
$toolsTarget = "$rootDir\tools\"

## copy tools into content
if (!(test-path $toolsTarget)) {
    mkdir $toolsTarget
    ## copy tools (nuget) into local
    Copy-Item -Recurse -Path ($toolsPath + '\*')  -Destination $toolsTarget

    delete_file($toolsTarget + '\init.ps1')
    delete_file($toolsTarget + '\uninstall.ps1')
}



## install required packages
$nuget = join-path $toolsTarget 'nuget.exe'

& $nuget Install NUnit.Runners -version 2.6.4 -SolutionDirectory $rootDir
& $nuget Install psake -version 4.1.0 -SolutionDirectory $rootDir

## copy scripts and add to solution

if (!(test-path $deployTarget)) {
  mkdir $deployTarget
  ## copy scripts into local
  $scriptsSource = join-path $installPath 'scripts\'

  Copy-Item -Path ($scriptsSource + '*')  -Destination $deployTarget
  ## Replace the solution name in the build file

  $replaceFile = $scriptsSource + 'build.ps1'
  $outFile = $deployTarget + 'build.ps1'

  replaceInFile $replaceFile  $outFile "SOLUTION_NAME" "$solutionName"

  ## add psake install location to teamcitywrapper
  $tcWrapper = $deployTarget + 'teamCityWrapper.ps1'

  replaceInFile $tcWrapper  $tcWrapper "PSAKE_LOCATION" "psake.4.1.0\tools"


  ## Add the items to our solution

  $deployFolder = $solutionNode.Projects | where-object { $_.ProjectName -eq "Deployment" } | select -first 1
  if(!$deployFolder) {
      $deployFolder = $solutionNode.AddSolutionFolder("deployment")
  }
  ## Check solution projects for Nunit
  
  foreach ($proj in (get-project -All)) {
    write-host "Project $($proj.Name) is in this solution."

    $proj.Object.References | foreach-object {
      if($_.Name -eq 'nunit.framework') { 
        write-host "NUnit project: $($proj.Name)" 

        $testsFile = $deployTarget + 'tests.psm1'

        ## check for unit or integration tests and amend build script accordingly
        if($proj.Name.ToLower().Contains('unittests')){
          replaceInFile $testsFile $testsFile "UNITTEST_PROJECT" $proj.Name
        }

        if($proj.Name.ToLower().Contains('integrationtests')){
          replaceInFile $testsFile $testsFile "INTTEST_PROJECT" $proj.Name
        }
      }
    }
  }

  $folderItems = Get-Interface $deployFolder.ProjectItems ([EnvDTE.ProjectItems])
      
  (ls $deployTarget -exclude "*.cmd", "*.exe") | foreach-object {
    $folderItems.AddFromFile($_.FullName)
  }

  (ls $toolsTarget -exclude "*.cmd", "*.exe") | foreach-object {
    $folderItems.AddFromFile($_.FullName)
  }
}

