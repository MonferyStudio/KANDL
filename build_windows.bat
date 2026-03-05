@echo off
echo Building KANDL for Windows...
echo Cleaning build caches...
call flutter clean
if exist ".dart_tool" rmdir /s /q ".dart_tool"
if exist "build" rmdir /s /q "build"
call flutter pub get
echo.
call flutter build windows --release
if errorlevel 1 (
    echo Build failed!
    exit /b 1
)

echo.
echo Packaging...
set SRC=build\windows\x64\runner\Release
set DEST=dist\kandl-windows

if exist "%DEST%" rmdir /s /q "%DEST%"
mkdir "%DEST%"

xcopy "%SRC%\*" "%DEST%\" /s /e /q /y

echo.
echo Done! Build ready in: %DEST%\
echo Run: %DEST%\kandl.exe
pause
