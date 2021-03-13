import xlwings as xw
import locate

def main():
    wb = xw.Book.caller()
    sheet = wb.sheets[0]
    if sheet["A1"].value == "Hello xlwings!":
        sheet["A1"].value = "Bye xlwings!"
    else:
        sheet["A1"].value = "Hello xlwings!"


@xw.func
def hello(name):
    return f"Hello {name}!"


@xw.sub
def hellosub():
    wb = xw.Book.caller()
    
    txt = wb.sheets[0].range('A1').value
    fout = locate.this_dir().joinpath("hello.txt")
    with fout.open("w") as fw:
        fw.write(txt)


if __name__ == "__main__":
    xw.Book("__bookname__.xlsm").set_mock_caller()
    main()
