@echo off
set task=default
set version=1.0.0.0

if not '%1' == '' set task=%1
if not '%2' == '' set version=%2

echo installing psake

..\tools\nuget Install psake -version 4.1.0 -SolutionDirectory ".."

echo Executing psake script TeamCityWrapper.ps1 with task "%task%" and version "%version%"

powershell.exe -NoProfile -ExecutionPolicy unrestricted -Command "& '.\TeamCityWrapper.ps1' %task% %version%;"
exit /B %errorlevel%