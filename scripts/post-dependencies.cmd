@staticmethod #  2>nul &@echo off
def _():''' 2>nul
    ::*******************************************************
    :: This is a .cmd header to define how to run this file
    ::*******************************************************
    call "%~dp0..\python" "%~dp0%~n0.cmd"
    exit /b %errorlevel%
'''

from locate import this_dir
import shutil
import os
from pathlib import Path

if __name__ == "__main__":

    #*********************************************************
    # Add vatools to site-packages
    #*********************************************************

    src = this_dir().joinpath("..", "vatools").resolve()
    dst = this_dir().joinpath("..", "bin", "python", "Lib", "site-packages", "vatools")

    shutil.rmtree(dst, ignore_errors=True)
    for i in src.glob("*"):
        if i.is_dir():
            continue
        rel = str(i)[len(str(src))+1:]
        j = dst.joinpath(rel)

        os.makedirs(j.parent, exist_ok=True)
        shutil.copy2(i,j)

    for i in dst.glob("*"):
        if i.exists() and i.is_dir() and i.name == "__pycache__":
            shutil.rmtree(i)
