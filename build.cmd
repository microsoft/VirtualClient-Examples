@echo Off

set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
set BUILD_CONFIGURATION=Debug

if /i "%~1" == "/?" goto :Usage
if /i "%~1" == "-?" goto :Usage
if /i "%~1" == "--help" goto :Usage

for %%a in (%*) do (
    if /i "%%a" == "--release" set BUILD_CONFIGURATION=Release
    if /i "%%a" == "--interactive" set RESTORE_INTERACTIVE=--interactive
)

if "%VCBuildVersion%" EQU "" (

    rem The 'CDP_FILE_VERSION_NUMERIC' environment variable is defined during a OneBranch official build and 
    rem represents the version of the build that will be producing the binaries/content. We use this version to
    rem make it easy for a user to determine which official build generated extensions and Toolkit packages.
    if "%CDP_FILE_VERSION_NUMERIC%" NEQ "" (
        set VCBuildVersion=%CDP_FILE_VERSION_NUMERIC%
    )
)

REM The "VCBuildVersion" environment variable is referenced by the MSBuild processes during build.
REM All binaries will be compiled with this version (e.g. .dlls + .exes). The packaging process uses 
REM the same environment variable to define the version of the NuGet package(s) produced. The build 
REM version can be overridden on the command line.
if "%VCBuildVersion%" EQU "" (
    echo:
    echo 'VCBuildVersion' environment variable not set. This defines the version for all project builds. Using default build version 0.0.1.
    echo:
    set VCBuildVersion=0.0.1
)

echo:
echo ********************************************************************
echo Building Extensions: %VCBuildVersion%
echo Repo Root          : %SCRIPT_DIR%
echo Configuration      : %BUILD_CONFIGURATION%
echo ********************************************************************
echo:

dotnet build "%SCRIPT_DIR%\src\VirtualClient.Extensions\VirtualClient.Extensions.sln" -c %BUILD_CONFIGURATION% %RESTORE_INTERACTIVE% && echo: || goto :End

echo:
echo ----------------------------------------------------------------------
echo Build Virtual Client Extensions: linux-x64
echo ----------------------------------------------------------------------
echo:
dotnet publish "%SCRIPT_DIR%\src\VirtualClient.Extensions\VirtualClient.Extensions.Packaging\VirtualClient.Extensions.Packaging.csproj" -r linux-x64 -c %BUILD_CONFIGURATION% --self-contained -p:InvariantGlobalization=true %RESTORE_INTERACTIVE% && echo: || goto :End

echo:
echo ----------------------------------------------------------------------
echo Build Virtual Client Extensions: linux-arm64
echo ----------------------------------------------------------------------
echo:
dotnet publish "%SCRIPT_DIR%\src\VirtualClient.Extensions\VirtualClient.Extensions.Packaging\VirtualClient.Extensions.Packaging.csproj" -r linux-arm64 -c %BUILD_CONFIGURATION% --self-contained -p:InvariantGlobalization=true %RESTORE_INTERACTIVE% && echo: || goto :End

echo:
echo ----------------------------------------------------------------------
echo Build Virtual Client Extensions: win-x64
echo ----------------------------------------------------------------------
echo:
dotnet publish "%SCRIPT_DIR%\src\VirtualClient.Extensions\VirtualClient.Extensions.Packaging\VirtualClient.Extensions.Packaging.csproj" -r win-x64 -c %BUILD_CONFIGURATION% --self-contained %RESTORE_INTERACTIVE% && echo: || goto :End

echo:
echo ----------------------------------------------------------------------
echo Build Virtual Client Extensions: win-arm64
echo ----------------------------------------------------------------------
echo:
dotnet publish "%SCRIPT_DIR%\src\VirtualClient.Extensions\VirtualClient.Extensions.Packaging\VirtualClient.Extensions.Packaging.csproj" -r win-arm64 -c %BUILD_CONFIGURATION% --self-contained %RESTORE_INTERACTIVE% && echo: || goto :End

goto :End


:Usage
echo:
echo Builds/compiles the source code in the repo. Pass in the --interactive
echo flag to enable interactive authentication with the target package feeds.
echo:
echo Usage:
echo ---------------------
echo %SCRIPT_DIR%^> set VCBuildVersion=1.0.0
echo %SCRIPT_DIR%^> %~nx0 [--release] [--interactive]
goto :Finish


:End
echo:
echo Build Stage Exit Code: %ERRORLEVEL%
echo:


:Finish
set SCRIPT_DIR=
set BUILD_CONFIGURATION=
set RESTORE_INTERACTIVE=
exit /B %ERRORLEVEL%