# These are project build parameters in TeamCity
# Depending on the branch, we will use different major/minor versions
$majorMinorVersionMaster = "%system.MajorMinorVersion.Master%"
$majorMinorVersionDevelop = "%system.MajorMinorVersion.Develop%"

# TeamCity's auto-incrementing build counter; ensures each build is unique
$buildCounter = "%build.counter%" 

# This gets the name of the current Git branch. 
$branch = "%teamcity.build.branch%"

# Sometimes the branch will be a full path, e.g., 'refs/heads/master'. 
# If so we'll base our logic just on the last part.
if ($branch.Contains("/")) 
{
  $branch = $branch.substring($branch.lastIndexOf("/")).trim("/")
}

Write-Host "Branch: $branch"

if ($branch -eq "master") 
{
 $buildNumber = "${majorMinorVersionMaster}.${buildCounter}"
 $simpleBuildNumber = $buildNumber
}
elseif ($branch -eq "develop") 
{
 $buildNumber = "${majorMinorVersionDevelop}.${buildCounter}"
 $simpleBuildNumber = $buildNumber
}
elseif ($branch -match "release-.*") 
{
 $specificRelease = ($branch -replace 'release-(.*)','$1')
 $buildNumber = "${specificRelease}-rc.${buildCounter}"
 $simpleBuildNumber = "${majorMinorVersionDevelop}.${buildCounter}"
}
else
{
 # If the branch starts with "feature-", just use the feature name
 $branch = $branch.replace("feature-", "")
 $buildNumber = "${majorMinorVersionDevelop}.${buildCounter}-${branch}"
 $simpleBuildNumber = "${majorMinorVersionDevelop}.${buildCounter}"
}

Write-Host "##teamcity[buildNumber '$buildNumber']"
Write-Host "##teamcity[setParameter name='simpleBuildNumber' value='$simpleBuildNumber']"