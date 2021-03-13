//#define NOSHELL

#define _WIN32_WINNT 0x0500
#include <windows.h>
#include <stdbool.h>
#include <tchar.h>

#ifdef NOSHELL
    int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
#else
    int main( int argc, char ** argv ) 
#endif
{

    // *******************************************
    //Get a direct path to the current running exe
    // *******************************************
    int size = 125;
    TCHAR* cmdPath = (TCHAR*)malloc(1);

    // read until GetModuleFileNameW writes less than its cap (of size)
    do {
        size *= 2;
        free(cmdPath);
        cmdPath = (TCHAR*)malloc(size*2);

        // If , then it's
    } while (GetModuleFileNameW(NULL, cmdPath, size) == size);


    // *******************************************
    // Get commandline string as a whole
    // *******************************************
    TCHAR* cmdArgs = GetCommandLineW();


    // *******************************************
    // Remove argument 0 from the commandline string
    // http://www.windowsinspired.com/how-a-windows-programs-splits-its-command-line-into-individual-arguments/
    // *******************************************
    bool inQuote = false;
    bool isArgs = false;
    int j = 0;

    for(int i=0; i<_tcslen(cmdArgs)+1; i++){
      //must be easier way to index unicode string
      TCHAR c = *(TCHAR *)(&cmdArgs[i*2]);
      
      if(c == L'"'){inQuote = !inQuote;}
      if(c == L' ' && !inQuote){ isArgs = true;}

      //do for both unicode bits
      cmdArgs[j*2  ] = cmdArgs[i*2  ];
      cmdArgs[j*2+1] = cmdArgs[i*2+1];

      //sync j with i after filepath
      if(isArgs){ j++; }
    }


    // *******************************************
    // Find basedir of cmdPath
    // *******************************************
    TCHAR* cmdBaseDir;
    cmdBaseDir = (TCHAR*) malloc((_tcslen(cmdPath)+1)*2);
    cmdBaseDir[0] = '\0';
    cmdBaseDir[1] = '\0';

    _tcscpy(cmdBaseDir, cmdPath);

    int nrOfSlashed = 0;
    int slashLoc = 0;
    for(int i=0; i<_tcslen(cmdBaseDir); i++){
      //must be easier way to index unicode string
      TCHAR c = *(TCHAR *)(&cmdBaseDir[i*2]);
      if(c == L'\\' || c == L'//'){
        nrOfSlashed+=1;
        slashLoc=i;
      }
    }

    if(nrOfSlashed==0){
      _tcscpy(cmdBaseDir, L".");
    }else{
      cmdBaseDir[2*slashLoc] = '\0';
      cmdBaseDir[2*slashLoc+1] = '\0';  
    }


    // *******************************************
    // Find filename without .exe
    // *******************************************
    TCHAR* cmdName;
    cmdName = (TCHAR*) malloc((_tcslen(cmdPath)+1)*2);
    cmdName[0] = '\0';
    cmdName[1] = '\0';

    _tcscpy(cmdName, cmdPath);

    cmdName = &cmdPath[slashLoc==0?0:slashLoc*2+2];
    int fnameend = _tcslen(cmdName);
    
    // if we run as path\program.exe then we need to truncate the .exe part
    if(0 < fnameend-4 && cmdName[(fnameend-4)*2] == '.'){
        cmdName[(fnameend-4)*2]   = '\0';
        cmdName[(fnameend-4)*2+1] = '\0';
    }

    //_tprintf(cmdName);
    //_tprintf(L"\n");

    // ********************************************
    // Bat name to be checked
    // ********************************************
    int totlen;

    TCHAR* pyFile1  = cmdBaseDir;
    TCHAR* pyFile2  = L"\\";          //first look in same directory
    TCHAR* pyFile3  = L"\\scripts\\"; //then in scripts
    TCHAR* pyFile4  = L"\\src\\";     //then in src
    TCHAR* pyFile5  = L"\\bin\\";     //then in bin
    TCHAR* pyFile6  = cmdName;
    TCHAR* pyFile7  = L".7z";        //Try 7z, zip, py
    TCHAR* pyFile8  = L".zip";
    TCHAR* pyFile9  = L".py";
    TCHAR* pyFile10  = L"";

    totlen = (_tcslen(pyFile1)+_tcslen(pyFile2)+_tcslen(pyFile3)+_tcslen(pyFile4)+_tcslen(pyFile5)+_tcslen(pyFile6)+_tcslen(pyFile7)+_tcslen(pyFile8)+_tcslen(pyFile9)+_tcslen(pyFile10));

    TCHAR* pyFile;
    pyFile = (TCHAR*) malloc((totlen+1)*2);
    pyFile[0] = '\0';
    pyFile[1] = '\0';

    for(int i=0; i<4; i++){
        for(int j=0; j<4; j++){
            _tcscpy(pyFile, pyFile1);
            if     (i==0){_tcscat(pyFile, pyFile2);}
            else if(i==1){_tcscat(pyFile, pyFile3);}
            else if(i==2){_tcscat(pyFile, pyFile4);}
            else if(i==3){_tcscat(pyFile, pyFile5);}

            //if the directory doesn't exist, break early
            if(0 != _waccess(pyFile, 0)){ break;}

            _tcscat(pyFile, pyFile6);
            if     (j==0){_tcscat(pyFile, pyFile7);}
            else if(j==1){_tcscat(pyFile, pyFile8);}
            else if(j==2){_tcscat(pyFile, pyFile9);}
            else if(j==3){_tcscat(pyFile, pyFile10);}
        
            //test if c:\path\to\cmdName.ext exists
            if(0 == _waccess(pyFile, 0)){
                goto breakout_launcher;
            }
        }
    }
    system("powershell -command \"[reflection.assembly]::LoadWithPartialName('System.Windows.Forms')|out-null;[windows.forms.messagebox]::Show('Could not find .7z, .zip, .py or no extension with the same filename in ., scripts, src or bin directory.', 'Execution error')\" ");
    exit(-1);
    breakout_launcher:;

    //_tprintf(pyFile);
    //_tprintf(L"\n");


    // ******************************************
    // Do we have a python.exe anywhere in parent directory?
    // ******************************************
    TCHAR* pythonPath;

    // cmdBaseDir + extra room
    pythonPath = (TCHAR*) malloc((_tcslen(cmdBaseDir)+_tcslen(L"\\pythonw.exe")+1)*2);
    pythonPath[0] = '\0';
    pythonPath[1] = '\0';

    _tcscpy(pythonPath, cmdBaseDir);
    totlen = _tcslen(pythonPath);

    //_tprintf(pythonPath);
    //_tprintf(L"\n");

    //128 is maximum number of possible sub-folders
    for(int i=0; i<128; i++){

        #ifdef NOSHELL
            _tcscat(pythonPath, L"\\pythonw.exe");
        #else
            _tcscat(pythonPath, L"\\python.exe");
        #endif
        

        //_tprintf(pythonPath);
        //_tprintf(L"\n");

        if(0 == _waccess(pythonPath, 0)){
            goto breakout_python;
        }

        //truncate back and then go to parent directory 
        pythonPath[totlen*2  ] = '\0';
        pythonPath[totlen*2+1] = '\0';

        if(totlen<=1) break;
        for(totlen = totlen-1; totlen>0; totlen--){
          //must be easier way to index unicode string
          TCHAR c = *(TCHAR *)(&pythonPath[totlen*2]);
          if(c == L'\\' || c == L'//'){
            pythonPath[totlen*2] = '\0';
            pythonPath[totlen*2+1] = '\0';
            break;
          }
        }

    }
    #ifdef NOSHELL
        system("powershell -command \"[reflection.assembly]::LoadWithPartialName('System.Windows.Forms')|out-null;[windows.forms.messagebox]::Show('Cannot find pythonw.exe in any parent directory.', 'Execution error')\" ");
    #else
        system("powershell -command \"[reflection.assembly]::LoadWithPartialName('System.Windows.Forms')|out-null;[windows.forms.messagebox]::Show('Cannot find python.exe in any parent directory.', 'Execution error')\" ");
    #endif
    
    exit(-1);
    breakout_python:;


    // *******************************************
    // Get into this form: "<path-to-python>" "<file-to-run>" arg1 arg2 ...
    // *******************************************
    //TCHAR* cmdLine?  = L"python.exe ";
    TCHAR* cmdLine1  = L"\"";
    TCHAR* cmdLine2  = pythonPath;
    TCHAR* cmdLine3  = L"\" \"";
    TCHAR* cmdLine4  = pyFile;
    TCHAR* cmdLine5  = L"\" "; 
    TCHAR* cmdLine6  = cmdArgs;
    TCHAR* cmdLine7 = L"";

    totlen = (_tcslen(cmdLine1)+_tcslen(cmdLine2)+_tcslen(cmdLine3)+_tcslen(cmdLine4)+_tcslen(cmdLine5)+_tcslen(cmdLine6)+_tcslen(cmdLine7));

    TCHAR* cmdLine;
    cmdLine = (TCHAR*) malloc((totlen+1)*2);
    cmdLine[0] = '\0';
    cmdLine[1] = '\0';

    
    _tcscpy(cmdLine, cmdLine1);
    _tcscat(cmdLine, cmdLine2);
    _tcscat(cmdLine, cmdLine3);
    _tcscat(cmdLine, cmdLine4);
    _tcscat(cmdLine, cmdLine5);
    _tcscat(cmdLine, cmdLine6);
    _tcscat(cmdLine, cmdLine7);


    // ************************************
    // Prepare and run CreateProcessW
    // ************************************
    PROCESS_INFORMATION pi;
    STARTUPINFO si;
        
    memset(&si, 0, sizeof(si));
    si.cb = sizeof(si);

    #ifdef NOSHELL
        CreateProcessW(NULL, cmdLine, NULL, NULL, TRUE, CREATE_NO_WINDOW, NULL, NULL, &si, &pi);
    #else
        CreateProcessW(NULL, cmdLine, NULL, NULL, TRUE, NULL,             NULL, NULL, &si, &pi);
    #endif

    // ************************************
    // Return ErrorLevel
    // ************************************
    DWORD result = WaitForSingleObject(pi.hProcess, INFINITE);

    if(result == WAIT_TIMEOUT){return -2;} //Timeout error

    DWORD exitCode=0;
    if(!GetExitCodeProcess(pi.hProcess, &exitCode) ){return -1;} //Cannot get exitcode

    return exitCode; //Correct exitcode
}

