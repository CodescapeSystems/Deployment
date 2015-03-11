# Codescape.Deployment

Codescape.Deployment is a wrapper for psake, nunit and team city to simplify deployments. It's primary aim is to keep build scripts within source control and easily sharable among the team.

We are adding this to github simply as an aid for others who may wish to employ a similar approach. Components used that this script is adapted for:
  - Teamcity build server - but builds can be run from command line
  - Heavy use of powershell and [psake] [1]
  - Nunit test runner

### Current Version
1.3.6

### Installation
To fully utilise this a couple of conventions are assumed.
To enable the installation to automatically configure the test scripts it is assumed that there is a project that inlcudes the name UnitTests and another with the name IntegrationTests *e.g. Project.UnitTests, or SomeIntegrationTests*. 

Install via nuget.

```sh
$  Install-Package Codescape.Deployment
```
This will create a new folder called deployment in the solution. The build.bat file can be called from the command line.

```
$ cd deploy
$ build <task> <version> <packageversion>
```

Tasks are defined as per psake syntax in the build.ps1 file. Please refer to the [psake documentation][2]
package version is optional, if not supplied it will use version

### Adding tasks
To try and increase the usefulness an attept has been made to modularize this slightly. Build.ps1 contains basic tasks which should be common to most builds.
- Compile (msbuild builds both debug and release at solution level)
- RestorePackages (nuget restore)
- PatchAssemblyInfo (sets the assemblyinfo.cs files to current version passed to build.bat)
 
There are two files that are icluded with this package that define additional tasks:
* tests.psm1 (includes tasks CleanResults, UnitTest, IntegrationTest)
* package.psm1 (includes package task - this is empty but stubbed to use with packableable deployments)

To add new tasks create a new file and add it to the deploy folder. Add the filename withour extension to the $addedTasks array at the top of the build.ps1 file.

```sh
$addedTasks = "package", "tests"
```
*Note: task files must be a .psm1 file*

### Todo's

 - Improve general robustness of scripts

License
----

MIT


[1]:https://github.com/psake/psake
[2]:https://github.com/psake/psake/wiki
