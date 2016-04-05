# Codescape.Deployment

Codescape.Deployment is a wrapper for psake, nunit and team city to simplify deployments. It's primary aim is to keep build scripts within source control and easily sharable among the team.

We are adding this to github simply as an aid for others who may wish to employ a similar approach. Components used that this script is adapted for:
  - Teamcity build server - but builds can be run from command line
  - Heavy use of powershell and [psake] [1]
  - Nunit test runner

### Current Version
2.0.1

### Release Notes
This major version uses a new 'developerConfig.json' file to keep development configuration separate from builds.
Upgraded NuGet.exe to version 3.3.0

### Installation
To fully utilise this a couple of conventions are assumed.
To enable the installation to automatically configure the test scripts it is assumed that there is a project that inlcudes the name UnitTests and another with the name IntegrationTests *e.g. Project.UnitTests, or SomeIntegrationTests*. 

Install via nuget.

```sh
$  Install-Package Codescape.Deployment
```
This will create a new folder called deployment in the solution. The build.bat file can be called from the command line.
Note: Visual Studio no longer supports solution wide nuget packages.

```
$ cd deploy
$ build <task> <version> <packageversion>
```

Tasks are defined as per psake syntax in the build.ps1 file. Please refer to the [psake documentation][2]
package version is optional, if not supplied it will use version

## Configuring development
The build now expect a developerConfig.json flie to exist at %USERPROFILE%\developerConfig.json
If this file is not present the scripts assume they are running on the build server.

The Json file looks as such.
```json
{
	"environment":"dev",
	"user":"USERNAME",
	"packageSources" : [
		"https://nuget.org/api/v2",
		"http://MYDevelopmentFeed.net/api/v2",
	]
}
```
The primary use of this is to separate the nuget sources from the projects allowing authenticated feeds to be used without checking in keys into source control.

### The build server
When on the server the scripts look for a __config.json file much in the same way the developer config is used. However is this is missing it will error. In a future release I will sync these files into one.
```json
{
"packageSources" : [
    "http://bcsnuget.azurewebsites.net/api/v2/",
    "http://MYProductionFeed.net/api/v2"
    ]
} 
```

### Adding tasks
To try and increase the usefulness an attept has been made to modularize this slightly. Build.ps1 contains basic tasks which should be common to most builds.
- Compile (msbuild builds both debug and release at solution level)
- RestorePackages (nuget restore)
- PatchAssemblyInfo (sets the assemblyinfo.cs files to current version passed to build.bat)
 
There are three files that are icluded with this package that define additional tasks:
* tests.psm1 (includes tasks CleanResults, UnitTest, IntegrationTest)
* package.psm1 (includes package task - this is empty but stubbed to use with packableable deployments)
* nuget.psm1 (includes CreateNugetPackages task - this will seach the project fot nuspec files and create packages from them)

To add new tasks create a new file and add it to the deploy folder. Add the filename withour extension to the $addedTasks array at the top of the build.ps1 file.

```sh
$addedTasks = "package", "tests"
```
*Note: task files must be a .psm1 file*

### Next releasee

 - Merge developerConfig and __config json files into a single one

License
----

MIT


[1]:https://github.com/psake/psake
[2]:https://github.com/psake/psake/wiki
