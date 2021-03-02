@call "%~dp0\activate-pythonva-environment.bat"
@call "%python_home%\scripts\xlwings.exe" addin install --unprotected
@call "%python_home%\scripts\xlwings.exe" config create --force
@pause