@echo off
echo ============================================
echo    Revit Add-in Build Script
echo ============================================
echo.

REM Lấy timestamp hiện tại
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"

echo Build timestamp: %datestamp%
echo.

REM Build project với MSBuild
echo Building project...
msbuild PipeEndpointUpdater.csproj /p:Configuration=Debug /p:Platform=AnyCPU /p:AssemblyNameSuffix=%datestamp% /verbosity:minimal

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo Build completed successfully!
echo.

REM Hiển thị file DLL đã tạo
echo Generated files:
dir /b bin\Debug\*.dll

echo.
echo To install to Revit, run: powershell -ExecutionPolicy Bypass -File install-to-revit.ps1
echo.
pause