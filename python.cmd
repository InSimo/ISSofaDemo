@echo off
setlocal EnableDelayedExpansion

rem Finds and execute the local python interpreter
rem (preferably the one of the build tree, else the one of ISExternals)

if defined VIRTUAL_ENV (
    rem Special case when being in a virtual env: just run the default interpreter
    python.exe %*
    goto :eof
)

rem First try the repository build tree 
rem Then test for possible known install tree folders (bin, bin64)
rem Finally try the ISExternals folder

goto :python_build_tree

:python_build_tree
rem We are not in a packaged bundle.
rem A .bin.json file should have been generated when building the project,
rem telling where the binary dir is in within the build tree.
if exist %~dp0\.bin.json (
    for /f "tokens=1,2 delims=:, " %%a in (' find ":" ^< "%~dp0\.bin.json" ') do (
        set "_%%~a=%%~b"
    )
    if not !_binary_dir! == "" if exist %~dp0\!_binary_dir!\python.exe (
        set bin_dir=%~dp0\!_binary_dir!
        goto :python_exe
    )
    
    goto :python_install_tree
    
)

:python_install_tree
goto :python_install_bin

:python_install_bin
if exist %~dp0\bin\python.exe (
    set bin_dir=%~dp0\bin
    goto :python_exe
) else (
    goto :python_install_bin64
)

:python_install_bin64
if exist %~dp0\bin64\python.exe (
    set bin_dir=%~dp0\bin64
    goto :python_exe
) else (
    goto :python_sources
)

:python_sources
rem Fallback to the Python distribution of the sources ( we have not yet built / installed the project )
set PYTHONDONTWRITEBYTECODE=1
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set ARCH=x86 || set ARCH=x64
set bin_dir=%~dp0\ISExternals\python2\win-!ARCH!
if exist !bin_dir!\python.exe (
    goto :python_exe
) else (
    rem Additional search path for ISExternals directory in the sources
    set bin_dir=%~dp0\IS\ISExternals\python2\win-!ARCH!
    goto :python_exe
)

:python_exe
set EMBEDDED_PYTHON_DIR=%bin_dir%
set PATH=%EMBEDDED_PYTHON_DIR%;%PATH%
echo [INFO] Using python executable from %EMBEDDED_PYTHON_DIR%
python.exe %*
goto :eof

:error
goto :pause

:pause
pause

