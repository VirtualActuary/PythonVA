:: This file will run on the developer's system right before this app is compiles into an installer
@echo off

:: Make sure internal library isn't included in the build
call "%~dp0\..\python" -m pip uninstall -y aa_py_core

:: Fix broken xlwings
del /f "%~dp0\..\bin\python\scripts\xlwings.exe"
xcopy /s "%~dp0\xlwings.cmd" "%~dp0\..\bin\python\scripts\xlwings.cmd"