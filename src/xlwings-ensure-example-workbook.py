import locate
import tempfile
from pathlib import Path
import subprocess
import shutil
from contextlib import contextmanager
from pathlib import Path
from typing import Union
import xlwings as xw


@contextmanager
def excel(
        path: Union[Path, str, None] = None,
        save: bool = False,
        quiet: bool = False,
        close: bool = False,
        kill: bool = False,
        must_exist: bool = False,
):
    """
    Open a book in an Excel app.

    :param path: The path to the Excel workbook. If it does not exist AND save is True, it will be created.
    :param save: Whether to save changes to the disk before closing the book. Ignored if no path is given.
    :param quiet: Whether to make Excel quiet and invisible.
    :param close: Whether to close the workbook when done.
    :param kill: Whether to kill Excel when done. Implies close.
    :param must_exist: Whether to raise an error if the path does not refer to an existing workbook.
        Ignored if no path is given.
    """
    if kill:
        # Killing Excel implies closing the workbook.
        close = True

    # Launch Excel.
    app = xw.App(visible=(not quiet))

    if quiet:
        # Be very paranoid about making sure that Excel is not shown.
        # Apparently the behaviour is not the same on all Excel versions, and this helps to catch more cases.
        app.api.EnableEvents = False
        app.api.DisplayAlerts = False
        app.api.Visible = False
        app.api.ScreenUpdating = False
        app.api.UserControl = False
        app.api.Interactive = False

    # Get the workbook.
    if path:
        path = Path(path)
        if path.exists():
            # Existing book.
            book = app.books.open(path)
        else:
            if must_exist:
                raise FileNotFoundError(f'File {path} does not exist.')

            # New book, maybe connected to a file.
            book = app.books[0]
            if save:
                # Make sure it exists on the disk before continuing.
                book.save(path=path)
    else:
        # New book, not connected to any file.
        book = app.books[0]

    try:
        yield book
    finally:
        if save:
            book.save()
        if close:
            book.close()
        if kill:
            app_pid = app.pid
            app.kill()



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