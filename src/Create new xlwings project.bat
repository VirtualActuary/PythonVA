@echo off
call "%~dp0\activate-pythonva-environment.bat"

set /p pname=Enter a name for your project: 

pushd "%UserProfile%\Documents"
    call "%python_home%\scripts\xlwings" quickstart %pname%
popd

start "" excel.exe "%UserProfile%\Documents\%pname%\%pname%.xlsm"
start "" spyder.exe "%UserProfile%\Documents\%pname%\%pname%.py"