@echo Off

set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

if /i "%~1" == "/?" goto :Usage
if /i "%~1" == "-?" goto :Usage
if /i "%~1" == "--help" goto :Usage
if /i "%~1" == "--interactive" set RESTORE_INTERACTIVE=--interactive

echo:
echo ********************************************************************
echo Restoring Packages:
echo Repo Root         : %SCRIPT_DIR%
echo ********************************************************************
echo:

call dotnet restore "%SCRIPT_DIR%\src\VirtualClient.Extensions\VirtualClient.Extensions.sln" %RESTORE_INTERACTIVE% && echo: || goto :End
goto :End


:Usage
echo:
echo Downloads dependency packages(e.g. NuGet) to the system. Pass in the --interactive
echo flag to enable interactive authentication with the target package feeds.
echo:
echo Usage:
echo ---------------------
echo %SCRIPT_DIR%^> %~nx0 [--interactive]
echo %SCRIPT_DIR%^> build.cmd
echo:
goto :Finish


:End
echo:
echo Restore Stage Exit Code: %ERRORLEVEL%
echo:


:Finish
set SCRIPT_DIR=
set RESTORE_INTERACTIVE=
exit /B %ERRORLEVEL%