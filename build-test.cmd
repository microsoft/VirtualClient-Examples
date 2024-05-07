@echo Off

set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
set BUILD_CONFIGURATION=Debug

if /i "%~1" == "/?" goto :Usage
if /i "%~1" == "-?" goto :Usage
if /i "%~1" == "--help" goto :Usage
if /i "%~1" == "--release" set BUILD_CONFIGURATION=Release

echo:
echo ********************************************************************
echo Running Tests :
echo Repo Root     : %SCRIPT_DIR%
echo Configuration : %BUILD_CONFIGURATION%
echo ********************************************************************
echo:

for /f "tokens=*" %%f in ('dir /B /S %SCRIPT_DIR%\src\*Tests.csproj') do (
    call dotnet test -c %BUILD_CONFIGURATION% "%%f" --no-restore --no-build --filter "(Category=Unit|Category=Functional)" --logger "console;verbosity=normal" && echo: || goto :End
)

goto :End


:Usage
echo:
echo Executes unit and functional tests within the repo. Run build.cmd first.
echo:
echo Usage:
echo ---------------------
echo %SCRIPT_DIR%^> set VCBuildVersion=1.0.0
echo %SCRIPT_DIR%^> build.cmd [--release]
echo %SCRIPT_DIR%^> %~nx0 [--release]
goto :Finish


:End
echo:
echo Test Stage Exit Code: %ERRORLEVEL%
echo:


:Finish
set BUILD_CONFIGURATION=
set SCRIPT_DIR=
exit /B %ERRORLEVEL%