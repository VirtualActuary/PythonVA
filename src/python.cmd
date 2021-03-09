@call "%~dp0\activate-pythonva-environment.cmd"
@call "%python_home%\python.exe" %*
@exit /b %errorlevel%