@echo off
setlocal enabledelayedexpansion
echo ============================================
echo   KANDL - Build System
echo ============================================
echo.
echo   1. Build ALL (Windows + APK + Web)
echo   2. Build Windows only
echo   3. Build APK only
echo   4. Build Web only
echo.
set /p CHOICE="Choose [1-4]: "

set DIST=dist
if not exist "%DIST%" mkdir "%DIST%"

set FAILED=0
set BUILD_WIN=0
set BUILD_APK=0
set BUILD_WEB=0

if "%CHOICE%"=="1" set BUILD_WIN=1& set BUILD_APK=1& set BUILD_WEB=1
if "%CHOICE%"=="2" set BUILD_WIN=1
if "%CHOICE%"=="3" set BUILD_APK=1
if "%CHOICE%"=="4" set BUILD_WEB=1

if %BUILD_WIN%==0 if %BUILD_APK%==0 if %BUILD_WEB%==0 (
    echo Invalid choice.
    pause
    exit /b 1
)
echo.

:: ============================================
:: SAFETY CHECK (protect web/ source folder)
:: ============================================
if not exist "web\icons\Icon-192.png" (
    echo [WARN] web\icons\Icon-192.png missing! Custom icons may have been deleted.
    echo        Restore your icons to web\icons\ before building.
    echo        Aborting to prevent shipping default Flutter icons.
    pause
    exit /b 1
)

:: ============================================
:: CLEAN (prevent stale dart2js cache)
:: ============================================
echo [Clean] Removing build caches...
echo --------------------------------------------
call flutter clean
if exist ".dart_tool" rmdir /s /q ".dart_tool"
if exist "build" rmdir /s /q "build"
call flutter pub get
echo [OK] Clean done.
echo.

:: ============================================
:: WINDOWS BUILD
:: ============================================
if %BUILD_WIN%==1 (
    echo [Windows] Building...
    echo --------------------------------------------
    call flutter build windows --release
    if errorlevel 1 (
        echo [FAIL] Windows build failed!
        set FAILED=1
    ) else (
        echo Packaging Windows...
        set WIN_SRC=build\windows\x64\runner\Release
        set WIN_DEST=%DIST%\kandl-windows

        if exist "!WIN_DEST!" rmdir /s /q "!WIN_DEST!"
        mkdir "!WIN_DEST!"
        xcopy "!WIN_SRC!\*" "!WIN_DEST!\" /s /e /q /y >nul

        if exist "%DIST%\kandl-windows.zip" del "%DIST%\kandl-windows.zip"
        powershell -Command "Compress-Archive -Path '!WIN_DEST!\*' -DestinationPath '%DIST%\kandl-windows.zip' -Force"
        echo [OK] Windows: %DIST%\kandl-windows.zip
    )
    echo.
)

:: ============================================
:: APK BUILD
:: ============================================
if %BUILD_APK%==1 (
    echo [APK] Building...
    echo --------------------------------------------
    call flutter build apk --release
    if errorlevel 1 (
        echo [FAIL] APK build failed!
        set FAILED=1
    ) else (
        copy /y "build\app\outputs\flutter-apk\app-release.apk" "%DIST%\kandl.apk" >nul
        echo [OK] APK: %DIST%\kandl.apk
    )
    echo.
)

:: ============================================
:: WEB BUILD
:: ============================================
if %BUILD_WEB%==1 (
    echo [Web] Building...
    echo --------------------------------------------
    call flutter build web --release --no-tree-shake-icons --pwa-strategy none --no-web-resources-cdn
    if errorlevel 1 (
        echo [FAIL] Web build failed!
        set FAILED=1
    ) else (
        echo Post-processing web build for itch.io...
        powershell -ExecutionPolicy Bypass -File "web_postprocess.ps1"

        :: Create zip
        if exist "%DIST%\kandl-web.zip" del "%DIST%\kandl-web.zip"
        powershell -Command "Compress-Archive -Path 'build\web\*' -DestinationPath '%DIST%\kandl-web.zip' -Force"
        echo [OK] Web: %DIST%\kandl-web.zip
    )
    echo.
)

:: ============================================
:: SUMMARY
:: ============================================
echo ============================================
echo   BUILD SUMMARY
echo ============================================
if %BUILD_WIN%==1 (
    if exist "%DIST%\kandl-windows.zip" (
        echo   [v] Windows : %DIST%\kandl-windows.zip
    ) else (
        echo   [x] Windows : FAILED
    )
)
if %BUILD_APK%==1 (
    if exist "%DIST%\kandl.apk" (
        echo   [v] APK     : %DIST%\kandl.apk
    ) else (
        echo   [x] APK     : FAILED
    )
)
if %BUILD_WEB%==1 (
    if exist "%DIST%\kandl-web.zip" (
        echo   [v] Web     : %DIST%\kandl-web.zip
    ) else (
        echo   [x] Web     : FAILED
    )
)
echo ============================================
echo   All outputs in: %DIST%\
echo ============================================
echo.

if %FAILED%==1 (
    echo Some builds failed. Check the output above.
) else (
    echo All builds succeeded!
)
pause
