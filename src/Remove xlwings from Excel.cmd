@call "%~dp0\activate-pythonva-environment.cmd"
@call "%python_home%\scripts\xlwings" addin remove

@if "%1" equ "" (
    @pause
)