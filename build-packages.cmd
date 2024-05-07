@echo Off

set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
set BUILD_CONFIGURATION=Debug

if /i "%~1" == "/?" goto :Usage
if /i "%~1" == "-?" goto :Usage
if /i "%~1" == "--help" goto :Usage
if /i "%~1" == "--release" set BUILD_CONFIGURATION=Release

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

set PackageDir=%SCRIPT_DIR%\src\VirtualClient.Extensions\VirtualClient.Extensions.Packaging
set PackageOutputDir=%SCRIPT_DIR%\out\packages

echo:
echo ********************************************************************
echo Packaging Extensions: %VCBuildVersion%
echo Repo Root           : %SCRIPT_DIR%
echo Configuration       : %BUILD_CONFIGURATION%
echo ********************************************************************
echo:

rem The packages project itself is not meant to produce a binary/.dll and thus is not built. However, to ensure
rem the requisite NuGet package assets file exist in the local 'obj' folder, we need to perform a restore.
call dotnet restore "%PackageDir%\VirtualClient.Extensions.Packaging.csproj" --force || goto :End

if EXIST "%PackageOutputDir%" (
    del "%PackageOutputDir%\*.zip" && echo: || goto :End
)

call dotnet pack "%PackageDir%\VirtualClient.Extensions.Packaging.csproj" --force --no-restore --no-build -c %BUILD_CONFIGURATION% -p:NuspecFile="%PackageDir%\example.virtualclient.extensions.nuspec" && echo: || goto :End

ren "%PackageOutputDir%\example.virtualclient.extensions*.nupkg" abc.virtualclient.extensions*.zip && echo: || goto :End
goto :End


:Usage
echo:
echo Builds packages from the artifacts/output of the build. Run build.cmd first.
echo:
echo Usage:
echo ---------------------
echo %SCRIPT_DIR%^> set VCBuildVersion=1.0.0
echo %SCRIPT_DIR%^> build.cmd [--release] [--interactive]
echo %SCRIPT_DIR%^> %~nx0 [--release]
goto :Finish


:End
echo:
echo Packaging Stage Exit Code: %ERRORLEVEL%
echo:


:Finish
set BUILD_CONFIGURATION=
set SCRIPT_DIR=
exit /B %ERRORLEVEL%