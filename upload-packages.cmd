@echo Off

if /i "%~1" == "/?" Goto :Usage
if /i "%~1" == "-?" Goto :Usage
if /i "%~1" == "--help" Goto :Usage
if /i "%~1" == "" Goto :Usage
if /i "%~2" == "" Goto :Usage
if /i "%~1" == "" Goto :Usage

set ExitCode=0
set PackageDirectory=%~1
set FeedUri=%~2

echo:
echo [Uploading NuGet Packages]
echo --------------------------------------------------
echo Package Directory : %PackageDirectory%
echo Feed              : %FeedUri%
echo:

for %%f in (%PackageDirectory%\*.nupkg) do (
    call dotnet nuget push %%f --api-key VSTS --timeout 1200 --source %FeedUri% %~3 && echo: || Goto :Error
)

Goto :End


:Usage
echo Invalid Usage. The package directory (where the .nupkg files are located) and the NuGet feed URI must be provided
echo on the command line.
echo:
echo Usage:
echo %~0 {packageDirectory} {nugetFeedUri} [{dotnet push args}]
echo:
echo Examples:
echo %~0 S:\source\one\repo\out\bin\Release\x64\Packages https://msazure.pkgs.visualstudio.com/_packaging/CRC/nuget/v3/index.json
echo %~0 S:\source\one\repo\out\bin\Release\x64\Packages https://msazure.pkgs.visualstudio.com/_packaging/CRC/nuget/v3/index.json --interactive
Goto :End


:Error
set ExitCode=%ERRORLEVEL%


:End
rem Reset environment variables
set PackageDirectory=
set FeedUri=

echo Build Stage Exit/Error Code: %ExitCode%
exit /B %ExitCode%