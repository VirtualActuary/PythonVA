@echo off
:: ************************************************************************
:: A file full of reusable bat routines to be called from an external file.
::
:: Usage: functions <functionname> <arg1> <arg2> ...
:: ************************************************************************

:: Redirect to the functions
call :%*
goto :EOF


::*********************************************************
:: https://stackoverflow.com/a/61552059
:: Parse commandline arguments into sane variables
:: See the following scenario as usage example:
:: >> thisfile.bat /a /b "c:\" /c /foo 5
:: >> CALL :ARG-PARSER %*
:: ARG_a=1
:: ARG_b=c:\
:: ARG_c=1
:: ARG_foo=5
::*********************************************************
:ARG-PARSER <arg1> <arg2> <etc>
    ::Loop until two consecutive empty args
    :__loopargs__
        IF "%~1%~2" EQU "" GOTO :EOF

        set "__arg1__=%~1"
        set "__arg2__=%~2"

        :: Capture assignments: eg. /foo bar baz  -> ARG_FOO=bar ARG_FOO_1=bar ARG_FOO_2=baz
        IF "%__arg1__:~0,1%" EQU "/"  IF "%__arg2__:~0,1%" NEQ "/" IF "%__arg2__%" NEQ "" (
            call :ARG-PARSER-HELPER %1 %2 %3 %4 %5 %6 %7 %8 %9
        )
        :: This is for setting ARG_FOO=1 if no value follows
        IF "%__arg1__:~0,1%" EQU "/" IF "%__arg2__:~0,1%" EQU "/" (
            set "ARG_%__arg1__:~1%=1"
        )
        IF "%__arg1__:~0,1%" EQU "/" IF "%__arg2__%" EQU "" (
            set "ARG_%__arg1__:~1%=1"
        )

        shift
    goto __loopargs__

goto :EOF

:: Helper routine for ARG-PARSER
:ARG-PARSER-HELPER <arg1> <arg2> <etc>
    set "ARG_%__arg1__:~1%=%~2"
    set __cnt__=0
    :__loopsubargs__
        shift
        set "__argn__=%~1"
        if "%__argn__%"      equ "" goto :EOF
        if "%__argn__:~0,1%" equ "/" goto :EOF

        set /a __cnt__=__cnt__+1
        set "ARG_%__arg1__:~1%_%__cnt__%=%__argn__%"
    goto __loopsubargs__
goto :EOF


:: ***********************************************
:: Remove trailing slash if exists
:: ***********************************************
:NO-TRAILING-SLASH <return> <input>
    set "__notrailingslash__=%~2"
    IF "%__notrailingslash__:~-1%" == "\" (
        SET "__notrailingslash__=%__notrailingslash__:~0,-1%"
    )
    set "%1=%__notrailingslash__%"
goto :EOF


:: ***********************************************
:: Expand path like c:\bla\fo* to c:\bla\foo
:: Expansion only works for last item!
:: ***********************************************
:EXPAND-ASTERIX <return> <filepath>
    ::basename with asterix expansion
    set "__inputfilepath__=%~2"
    call :NO-TRAILING-SLASH __inputfilepath__ "%__inputfilepath__%"

    set "_basename_="
    for /f "tokens=*" %%F in ('dir /b "%__inputfilepath__%" 2^> nul') do (
        set "_basename_=%%F"
        goto :__endofasterixexp__
    )
    :__endofasterixexp__

    ::concatenate with dirname is basename found (else "")
    if "%_basename_%" NEQ "" (
        set "%~1=%~dp2%_basename_%"
    ) ELSE (
        set "%~1="
    )

    set _basename_=
goto :EOF


:: ***********************************************
:: Extract an archive file using 7zip
:: ***********************************************
:EXTRACT-ARCHIVE <7zipexe> <srce> <dest>
    ::Try to make a clean slate for extractor
    call :DELETE-DIRECTORY "%~3" >nul 2>&1
    mkdir "%~3" 2>NUL

    ::Extract to output directory
    call "%~1" x -y "-o%~3" "%~2"

goto :EOF


:: ***********************************************
:: Windows del command is too limited
:: ***********************************************
:DELETE-DIRECTORY <dirname>
    if not exist "%~1" ( goto :EOF )
    powershell -Command "Remove-Item -LiteralPath '%~1' -Force -Recurse"

goto :EOF


::*********************************************************
:: Execute a command and return the value
::*********************************************************
:EXEC <returnvar> <returnerror> <command>
    set "errorlevel=0"
    FOR /F "tokens=* USEBACKQ" %%I IN (`%3`) do (
        set "%1=%%I"
        goto :_done_first_line_
    )
    :_done_first_line_
    set "%2=%errorlevel%"
goto :EOF


:: ***********************************************
:: Return full path to a filepath
:: ***********************************************
:FULL-PATH <return> <filepath>
    set "%1=%~dpnx2"
goto :EOF


::*********************************************************
:: Split a file into its dir, name, and ext
::*********************************************************
:DIR-NAME-EXT <returndir> <returnname> <returnext> <inputfile>
    set "%~1=%~dp4"
    set "%~2=%~n4"
    set "%~3=%~x4"
goto :EOF


::*********************************************************
:: Get the local date in format yyyy-mm-dd
::*********************************************************
:LOCAL-DATE <return>

    :: adapted from http://stackoverflow.com/a/10945887/1810071
    set "MyDate="
    for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
    for /f %%x in ('wmic path win32_localtime get /format:list ^| findstr "="') do set %%x
    set fmonth=00%Month%
    set fday=00%Day%
    set _today_=%Year%-%fmonth:~-2%-%fday:~-2%
    set "%~1=%_today_%"
goto :EOF


::*********************************************************
:: Get the local time in format hhmmss.ms
::*********************************************************
:LOCAL-TIME <return>
    set "_tmp_=%time: =0%"
    set "_tmp_=%_tmp_:,=%"
    set "_tmp_=%_tmp_::=%"
    set "%1=%_tmp_%"
goto :EOF


::*********************************************************
:: Get a timestamp in format yyyy-mm-dd-hhmmss.ms
::*********************************************************
:TIME-STAMP <return>
    call :LOCAL-DATE _date_
    call :LOCAL-TIME _time_
    set "%~1=%_date_%-%_time_%"

goto :EOF


:: ***********************************************
:: Add a path to windows path
:: ***********************************************
:ADD-TO-PATH <path>
    call :FULL-PATH _path_ "%~1"
    set "PATH=%_path_%;%PATH%"
goto :EOF


::*********************************************************
:: Test if the parameters of a function is as expected
::*********************************************************
:TEST-OUTCOME <expected> <actual> <testname>
    if "%~1" EQU "%~2" goto :EOF

    echo *********************************************
    if "%~3" NEQ "" echo For test %~3
    echo Expected: %1
    echo Got     : %2
    echo:

goto :EOF


:: ***********************************************
:: Convert content of a variable to upper case. Expensive O(26N)
:: ***********************************************
:TO-UPPER <return> <text>
    set "_text_=%~2"
    :: https://stackoverflow.com/a/2773504
    for %%L IN (^^ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO call SET "_text_=%%_text_:%%L=%%L%%"
    set "%1=%_text_%"

GOTO :EOF


:: ***************************************************
:: Test if a directory is empty
:: **************************************************
:IS-DIRECTORY-EMPTY <flag>
    set "%~1=0"
    for /F %%i in ('dir /b "c:\test directory\*.*"') do (
       echo set "%~1=1"
       goto :eof
    )
goto :eof


:: ***********************************************
:: Test if PythonVA is already in path
:: ***********************************************
:TEST-PYTHONVA-PATHS <testflag>
    set "%~1=1"

    call :FULL-PATH teststring "%~dp0..\bin\python"
    call set "xpath_mutated=x%%PATH:%teststring%=xxx%%"
    if "x%PATH%" equ "%xpath_mutated%" (
        set "%~1=0"
    )

goto :EOF


:: ***********************************************
:: End in error
:: ***********************************************
:EOF-DEAD
    exit /b 1

GOTO :EOF
