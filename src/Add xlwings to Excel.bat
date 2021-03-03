@call "%~dp0\activate-pythonva-environment.bat"
@call "%python_home%\scripts\xlwings.exe" addin install
@call "%python_home%\scripts\xlwings.exe" config create --force
@call "%python_home%\python.exe" "%~dp0xlwings-ensure-example-workbook.py"

@if "%1" equ "" (
    @pause
)