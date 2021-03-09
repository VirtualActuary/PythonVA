@call "%~dp0\activate-pythonva-environment.cmd"
@call "%python_home%\scripts\xlwings" addin install
@call "%python_home%\scripts\xlwings" config create --force
@call "%python_home%\python.exe" "%~dp0xlwings-ensure-example-workbook.py"

@if "%1" equ "" (
    @pause
)