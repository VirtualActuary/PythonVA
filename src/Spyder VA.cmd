@call "%~dp0\activate-pythonva-environment.cmd"
@call "%python_home%\scripts\spyder.exe" %*
@exit /b %errorlevel%