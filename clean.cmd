@echo Off

set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

if /i "%~1" == "/?" goto :Usage
if /i "%~1" == "-?" goto :Usage
if /i "%~1" == "--help" goto :Usage

call dir /A:d /B %SCRIPT_DIR%\out 1>nul 2>nul && (
    echo:
    for /F "delims=" %%d in ('dir /A:d /B %SCRIPT_DIR%\out') do (
        echo Clean: %SCRIPT_DIR%\out\%%d
        call rmdir /Q /S "%SCRIPT_DIR%\out\%%d" && rem || goto :End
    )
)

call dir /S /A:d /B %SCRIPT_DIR%\src\*obj 1>nul 2>nul && (
    for /F "delims=" %%d in ('dir /S /A:d /B %SCRIPT_DIR%\src\*obj') do (
        rem Step through all subdirectories of the /src directory to find
        rem /obj directories within individual projects. These contain various types
        rem of intermediates related to NuGet package caches that we want to clean.
        echo Clean: %%d
        call rmdir /Q /S "%%d" && rem || goto :End
    )
)

goto :End


:Usage
echo:
echo Deletes build artifacts from the repo.
echo:
echo Usage:
echo ---------------------
echo %SCRIPT_DIR%^> %~nx0
goto :Finish


:End
echo:
echo Clean Stage Exit/Error Code: %ERRORLEVEL%
echo:


:Finish
set SCRIPT_DIR=
exit /B %ERRORLEVEL%
