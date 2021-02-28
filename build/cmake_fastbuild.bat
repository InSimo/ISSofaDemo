@echo off
REM enable delayed expansion to be able to modify existing variables
setlocal enableDelayedExpansion

REM if you customize this script and move it, change this to point to the main CMakeLists.txt file
set cmake_source_dir=%~dp0

REM By default we place the build tree outside the source tree: ..\fastbuild_%suffix%
REM You can customize this with the environment variable FASTBUILD_BUILD_DIR
REM %suffix% will be either x86 or x64 depending on the platform (x64 is chosen if QTDIR64 is set).
REM %dirname% can be used to build a name depending on the project's root source directory name.
REM
REM Examples:
REM   FASTBUILD_BUILD_DIR=build\fastbuild_%suffix%        (previous behavior)
REM   FASTBUILD_BUILD_DIR=fastbuild_%suffix%              (within the source tree)
REM   FASTBUILD_BUILD_DIR=..\fb_%dirname%_%suffix%        (outside but using dirname so multiple
REM                                                        projects can be built side by side)
REM   FASTBUILD_BUILD_DIR=D:\fastbuild\%dirname%_%suffix% (absolute path to another disk)
REM
REM You can also specify a different build dir for a project by setting the variable
REM FASTBUILD_BUILD_DIR_%dirname%, for example: FASTBUILD_BUILD_DIR_src=..\fb_%suffix%

if not defined FASTBUILD_BUILD_DIR set FASTBUILD_BUILD_DIR=..\fastbuild_%%suffix%%

REM Look for dependencies

where /q cmake-gui.exe
if errorlevel 1 (
    echo cmake-gui.exe not in PATH, trying default locations
    set cmake_path="C:\Program Files\CMake\bin"
    if not exist !cmake_path!\cmake-gui.exe set cmake_path="C:\Program Files (x86)\CMake\bin"
    if not exist !cmake_path!\cmake-gui.exe goto error_path
    echo cmake-gui.exe found in !cmake_path!
    set PATH=!cmake_path!;!PATH!
) else echo cmake-gui.exe found in PATH

where /q fbuild.exe
if errorlevel 1 (
    echo fbuild.exe not in PATH, trying default location
    set fastbuild_path="%FASTBUILDPATH%"
    if not exist !fastbuild_path!\fbuild.exe set fastbuild_path="C:\Program Files\FASTBuild"
    if not exist !fastbuild_path!\fbuild.exe goto error_path
    echo fbuild.exe found in "!fastbuild_path!"
    set PATH=!fastbuild_path!;!PATH!
) else echo fbuild.exe found in PATH

set tools_dir=%cmake_source_dir%\..\ISExternals\tools
if not exist %tools_dir%\awk.exe set tools_dir=%cmake_source_dir%\..\IS\ISExternals\tools
if not exist %tools_dir%\awk.exe goto error_path

REM Select Visual C++ version and architecture

set vs14_common_tools=%VS140COMNTOOLS%
set vs14_vcvarsall="%vs14_common_tools%..\..\VC\vcvarsall.bat"

if "%~1"=="" goto default
if "%1" =="x86" goto x86
if "%1" =="x64" goto x64

:default
if defined QTDIR64 (
    goto x64
) else (
    goto x86
)

:x86 
echo Enabling Visual Studio 2015 x86
call %vs14_vcvarsall% x86
set suffix=x86
goto cmake

:x64
echo Enabling Visual Studio 2015 x64
call %vs14_vcvarsall% x86_amd64
set suffix=x64
set PATH=C:\Python27_64;%PATH%
goto cmake

REM Run CMake

:cmake
call :ResolveNameExt dirname "%cmake_source_dir%\.."
REM use FASTBUILD_BUILD_DIR_%dirname% if it exists
if defined FASTBUILD_BUILD_DIR_%dirname% call set FASTBUILD_BUILD_DIR=%%FASTBUILD_BUILD_DIR_%dirname%%%
rem call set cmake_build_dir=%%FASTBUILD_BUILD_DIR_%dirname%%%
rem if not "%cmake_build_dir%"=="" set FASTBUILD_BUILD_DIR=%cmake_build_dir%
REM replace variables inside FASTBUILD_BUILD_DIR
call set FASTBUILD_BUILD_DIR=%FASTBUILD_BUILD_DIR%
REM convert to absolute path
pushd "%cmake_source_dir%\.."
call :ResolvePath cmake_build_dir "%FASTBUILD_BUILD_DIR%"
popd
echo CMake source directory: %cmake_source_dir%
echo CMake build directory: %cmake_build_dir%

if not exist %cmake_build_dir% mkdir %cmake_build_dir%
cd %cmake_build_dir%
cmake-gui %cmake_source_dir%
if errorlevel 1 goto :error_cmake
if not exist fbuild.bff goto error_fbuild
goto postprocess

REM Post process generated fbuild file

:postprocess
if exist %cmake_source_dir%\cmake_fastbuild_postprocess.awk (
  %tools_dir%\awk -f %cmake_source_dir%\cmake_fastbuild_postprocess.awk < fbuild.bff > fbuild.tmp
  if errorlevel 1 goto :error_awk
  move /Y fbuild.tmp fbuild.bff
)
goto fastbuild

REM Run FASTBuild to generate solution

:fastbuild 
fbuild solution
goto end

:error_path
echo "PATH error: %PATH%"
goto pause

:error_cmake
echo "CMake GUI exited with an error"
goto pause

:error_fbuild
echo "could not find %cd%\fbuild.bff"
goto pause

:error_awk
echo awk.exe not in %tools_dir% or error in %cmake_source_dir%\cmake_fastbuild_postprocess.awk
goto pause

:pause
pause

:end
cd %cmake_source_dir%
exit 0

rem Resolve path to absolute.
rem Param 1: Name of output variable.
rem Param 2: Path to resolve.
rem Return: Resolved absolute path.
:ResolvePath
    set %1=%~f2
    exit /b

rem Resolve path to name and extension
rem Param 1: Name of output variable.
rem Param 2: Path to resolve.
rem Return: Resolved name and extension.
:ResolveNameExt
    set %1=%~nx2
    exit /b
