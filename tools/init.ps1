param($installPath, $toolsPath, $package, $project)


$rootDir = (Get-Item $installPath).parent.parent.fullname
$deployTarget = "$rootDir\Deploy\"


$deploySource = join-path $installPath 'tools/deploy'

if (!(test-path $deployTarget)) {
    mkdir $deployTarget
}

mkdir tools