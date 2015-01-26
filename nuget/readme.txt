This is a simple psake bootstrap.

I have tried to make it somewhat generic but this is not intended to be used without some 'tweaking' effort.

There are a number of points to note.

This installer automatically installs two nuget packages in the solutions packages directory:
NUnit.CommandLineRunners
psake

Psake is required to run the build script.
NUnit runners is used to run unittests from the command line. This can be optionally disabled in the scripts.

The installation automatically locates the solution name and sets up the default build scripts to build this.
In addition the installation will also look for projects with NUnit installed. It will generate the NUnit script to run these providing the
test projects contain UnitTests and IntegrationTests.

######### Running ##########

the build.bat file can be called to run the build script from the command line. This takes the task parameter.
>> build [task]
The build.bat also invokes the teamcity wrapper for integration with TC. This wrapper although part of the setup is only required if
test projects are called as part of the build.

If task is omitted the default task is run. This is compile unless altered in build.ps1.

############ editing build scripts #############
For more information please refer to psake and powershell documentation

Notes on this implementation.
build.ps1 is the default build script. this defines core tasks like restore packages and compile

In addition this imports two other task files.
tests.psm1 -> this file defines cleantests/unittest/integrationtest tasks. As mentioned this file is automatically configures with nunit if test projects are found within the solution

package.psm1 -> this task is imported but is empty (commented out) the reason being that package tasks require *.csproj files to build against.
This is also where options such as octopack would be defined if required. This will likely be of use if you have a web/service application within your solution.


To remove/add task modules to the script add/remove the filename (without extension) from this line:
 $addedTasks = "package", "tests"
 
 NOTE: task files must use the extension psm1






