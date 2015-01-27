# Codescape.Deployment

Codescape.Deployment is a wrapper for psake, nunit and team city to simplify deployments. It's primary aim is to keep build scripts within source control and easily sharable among the team.

We are adding this to github simply as an aid for others who may wish to employ a similar approach. Components used that this script is adapted for:
  - Teamcity build server - but builds can be run from command line
  - Heavy use of powershell and [psake] [1]
  - Nunit test runner

### Version
1.2.3

### Installation
To fully utilise this a couple of conventions are assumed.
To enable the installation to automatically configure the test scripts it is assumed that there is a project that inlcudes the name UnitTests and another with the name IntegrationTests *e.g. Project.UnitTests, or SomeIntegrationTests*. 

Install via nuget.

```sh
$  Install-Package Codescape.Deployment
```
This will create a new folder called deployment in the solution. The build.bat file can be called from the command line.

```sh
$ cd deploy
$ build <task> <version>
```

Tasks are defined as per psake syntax in the build.ps1 file.

### Adding tasks

To add new tasks

### Todo's

 - Write Tests

License
----

MIT


[1]:https://github.com/psake/psake
