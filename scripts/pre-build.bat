:: This file will run on the developer's system right before this app is compiles into an installer
@echo off

:: Make sure internal library isn't included in the build
call "%~dp0\..\python" -m pip uninstall -y aa_py_core

:: Fix unmovable pip binaries
:: call "%~dp0\..\python" "%~dp0..\src\fix-pip-python-binaries.py" "%~dp0\..\bin\python\Scripts"
