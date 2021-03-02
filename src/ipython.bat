@call "%~dp0\activate-pythonva-environment.bat"
@call "%python_home%\scripts\ipython.exe" %*
@exit /b %errorlevel%