@call "%~dp0\activate-pythonva-environment.bat"
@call "%python_home%\scripts\spyder.exe" %*
@exit /b %errorlevel%