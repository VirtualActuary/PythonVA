@staticmethod #  2>nul &@echo off
def _():r''' 2>nul
    ::*******************************************************
    :: This is a .cmd header to define how to run this file
    ::*******************************************************
    call "%~dp0\activate-pythonva-environment.cmd"

    call "python" "%~dp0%~n0.cmd"

    set /p xlfile=<"%temp%\xlwings_xlfile.txt"
    set /p pyfile=<"%temp%\xlwings_pyfile.txt"

    start "" excel.exe "%xlfile%"
    start "" "spyder" "%pyfile%"

    exit /b %errorlevel%
'''

import os
from pathlib import Path
from path import Path as _Path
import subprocess
import shutil
import tempfile

def sanitize_name(txt):
    letters = "abcdefghijklmnopqrstuvwxyz"
    numbers = "0123456789"

    txt = txt.strip()
    if txt[:1] in numbers:
        txt = "_"+txt

    legal = set(letters + letters.upper() + numbers)
    txt = ''.join([i if i in legal else "_" for i in txt])

    return txt


if __name__ == "__main__":
    txt = input("Enter a name for your project: ")
    txt = sanitize_name(txt)

    docs = Path(os.path.expanduser('~/Documents'))

    for i in range(1000000):
        postfix = f"({i})"
        if i ==0:
            postfix = ""

        outpath = docs.joinpath(f"{txt}{postfix}")
        if outpath.exists():
            continue

        os.makedirs(outpath, exist_ok=True)
        break

    with _Path(outpath):
        subprocess.call(["xlwings", "quickstart", txt])
        shutil.move(f"{txt}/{txt}.py", f"{txt}.py")
        shutil.move(f"{txt}/{txt}.xlsm", f"{txt}.xlsm")
    shutil.rmtree(outpath.joinpath(txt))


    # Write out to temp files readible by batch
    tmp = Path(tempfile.mktemp()).parent

    with open(tmp.joinpath("xlwings_pyfile.txt"), "w") as f:
        f.write(str(outpath.joinpath(txt+".py")))

    with open(tmp.joinpath("xlwings_xlfile.txt"), "w") as f:
        f.write(str(outpath.joinpath(txt+".xlsm")))


    