import os
from pathlib import Path
import locate
import zipfile
import os
import shutil
import re
import sys


test_pyw = re.compile(r"#!.*\\pythonw.exe")
alternative_pip_cmd = r"""
@echo off
:: Don't error when testing if pip entry is overwritten
if "%~1" equ "pythonva-test-for-custom-pip" (
    exit /b 0
)

call "%~dp0..\python.exe" -m pip %*
set "__e__=%errorlevel%"
call "%~dp0..\python.exe" "%~dp0fix-pip-python-binaries.py" "%~dp0."
exit /b %__e__%
"""


def get_wrapper_path(scripts_directory: Path):
    """
    This function is either run from the "python\Scripts" directory or from the
    original source directory. In the case of the original directory, we
    want to copy over all the necessary resources to overwrite the default
    python exe wrappers.
    
    The function returns the paths of the resources located in "python\Scripts"
    """
    
    py_wrap_origin = locate.this_dir().joinpath("..", "resources", "python-exe-wrappers", "python-exe-wrapper.exe") 
    pyw_wrap_origin = locate.this_dir().joinpath("..", "resources", "python-exe-wrappers", "pythonw-exe-wrapper.exe")
    pip_wrap_origin = locate.this_dir().joinpath("..", "resources", "batch-exe-wrappers", "launcher.exe")
    
    py_wrap = scripts_directory.joinpath("(python-exe-wrapper.exe)")
    pyw_wrap = scripts_directory.joinpath("(pythonw-exe-wrapper.exe)")
    pip_wrap = scripts_directory.joinpath("(pip-exe-wrapper.exe)")
    
    if pyw_wrap_origin.exists() and py_wrap_origin.exists():
        shutil.copy2(py_wrap_origin, py_wrap)
        shutil.copy2(pyw_wrap_origin, pyw_wrap)
        shutil.copy2(pip_wrap_origin, pip_wrap)
        shutil.copy2(__file__, scripts_directory.joinpath("fix-pip-python-binaries.py"))
    
    return py_wrap, pyw_wrap, pip_wrap



def clean_up_scripts_directory(scripts_directory: Path):
    """
    This function ensures that all the scripts in "python\Scripts" are made
    to run after the distrobution has changed directories. This involves 
    replacing the original binaries with alternative wrappers and replacing
    the pip launcher with an alternative to ensure this cleanup routine
    is run after ever pip call.
    """
    
    py_wrap, pyw_wrap, pip_wrap = get_wrapper_path(scripts_directory)
    
    
    pip_exes = [scripts_directory.joinpath("pip.exe")]+list(scripts_directory.glob("pip3*.exe"))
    for pip_exe in pip_exes:
        pip_cmd = pip_exe.parent.joinpath(os.path.splitext(pip_exe.name)[0]+".cmd")
        if ((pip_exe.exists() and zipfile.is_zipfile(pip_exe)) or not pip_cmd.exists()):
            with open(pip_cmd, "w") as fw:
                fw.write(alternative_pip_cmd)
                shutil.copy(pip_wrap, pip_exe)
    
    for orphan in [i for i in scripts_directory.glob("*") if os.path.splitext(i.name[-1]) == '']:
        if not orphan.parent.joinpath(os.path.splitext(orphan.name)[0]+".exe").exists():
            if zipfile.is_zipfile(orphan):
                os.remove(orphan)
    
    
    for exe in scripts_directory.glob("*.exe"):
        szip = exe.parent.joinpath(os.path.splitext(exe.name)[0])
        
        if zipfile.is_zipfile(exe):
            shutil.copy(exe, szip)
            
            with open(szip, "br") as f:
                use_pyw = True if test_pyw.findall(f.read().decode("utf-8", errors="ignore")) else False
            
            if use_pyw:
                shutil.copy2(pyw_wrap, exe)
            else:
                shutil.copy2(py_wrap, exe)



if __name__ == "__main__":
    
    if len(sys.argv) != 2:
        print(f"Usage: python {__file__} <python-script-dir>")
    else:
        clean_up_scripts_directory(Path(sys.argv[1]))
    