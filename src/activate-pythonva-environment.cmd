@echo off
set functions="%~dp0functions.cmd"

:: Set convenient variables
call %functions% FULL-PATH pythonva_home "%~dp0.."
call %functions% FULL-PATH python_home "%~dp0..\bin\python"
call %functions% FULL-PATH python_scripts "%~dp0..\bin\python\scripts"


:: Do a pip overwrite in case pip replaced itself
call "%python_scripts%\pip" pythonva-test-for-custom-pip > nul 2>&1 
if "%errorlevel%" neq "0" (
    call "%python_home%\python.exe" "%~dp0fix-pip-python-binaries.py" "%python_scripts%"
)


:: Return early if Windows Path environment is already set
call %functions% TEST-PYTHONVA-PATHS testflag
if "%testflag%" equ "1" (
    goto :EOF
)


:: Add all paths to Windows environment
call %functions% ADD-TO-PATH "%python_home%"
call %functions% ADD-TO-PATH "%python_scripts%"