import locate
import tempfile
from pathlib import Path
import subprocess
from aa_py_core.xl.context import excel
import shutil


szipbin = locate.this_dir().parent.joinpath("bin", "7z.exe")
fiboutput = Path(tempfile.mktemp())
fibzip = locate.this_dir().parent.joinpath("resources", "fibonacci.zip")


subprocess.check_output(
    [str(szipbin), 'x', str(fibzip), '-pabc123', f'-o{fiboutput}', '-aoa', '-y']
)

excel(
    path=fiboutput.joinpath("fibonacci.xlsm"),
    save=True,
    quiet=True,
    kill=True
    )

shutil.rmtree(fiboutput, ignore_errors=True)