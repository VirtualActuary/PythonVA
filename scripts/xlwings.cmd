@echo off
call "%~dp0..\python.exe" "%~dp0..\Lib\site-packages\xlwings\cli.py" %*
exit /b %errorlevel%