import inspect
from locate.locate import _file_path_from_stack_frame
import warnings
from pathlib import Path
import os

_header = r"""@staticmethod #  2>nul &@echo off
def _():''' 2>nul
    ::*******************************************************
    :: This is a .cmd header to define how to run this file
    ::*******************************************************
    if not exist "%localappdata%\PythonVA\bin\python\python.exe" (
        powershell -command "[reflection.assembly]::LoadWithPartialName('System.Windows.Forms')|out-null;[windows.forms.messagebox]::Show(\"Please install PythonVA in order to run this script:`r`n  https://github.com/AutoActuary/PythonVA/releases\", 'PythonVA not installed!')"
        exit /b -1
    )

    call "%localappdata%\PythonVA\bin\python\python.exe" "%~dp0%~n0.cmd"
    __pause__
    exit /b %errorlevel%
'''
"""

def create_cmd_counterpart(pause=True):
    caller_file = _file_path_from_stack_frame(inspect.stack()[1].frame)
    if caller_file is None:
        warnings.warn("Cannot infer the caller filepath to create cmd file.", UserWarning)
        return

    fname, fext = os.path.splitext(str(caller_file))

    if fext == ".cmd":
        return

    header = _header.replace("__pause__", "pause" if pause else "")
    with caller_file.open("r") as f:
        txt = f.read()
    txt_out = header + txt

    fpath = fname+".cmd"
    with open(fpath, "w") as f:
        f.write(txt_out)
