@call "%~dp0\activate-pythonva-environment.bat"
@call "%python_home%\python.exe" %*
@exit /b %errorlevel%