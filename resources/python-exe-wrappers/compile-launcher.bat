@echo off
cd "%~dp0"
tcc -D_UNICODE -DNOSHELL python-exe-wrapper.c -luser32 -lkernel32 -mwindows -o pythonw-exe-wrapper.exe
tcc -D_UNICODE  python-exe-wrapper.c -luser32 -lkernel32 -o python-exe-wrapper.exe
