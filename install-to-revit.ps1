# PowerShell script để install Revit add-in tự động
param(
    [string]$Configuration = "Debug",
    [string]$RevitVersion = "2023"
)

# Định nghĩa các đường dẫn
$ProjectDir = $PSScriptRoot
$BinDir = Join-Path $ProjectDir "bin\$Configuration"
$RevitAddInsDir = "C:\Program Files\Autodesk\Revit $RevitVersion\AddIns"
$UserAddInsDir = "$env:APPDATA\Autodesk\Revit\Addins\$RevitVersion"

Write-Host "=== Revit Add-in Installation Script ===" -ForegroundColor Green
Write-Host "Project Directory: $ProjectDir"
Write-Host "Configuration: $Configuration"
Write-Host "Revit Version: $RevitVersion"
Write-Host ""

# Kiểm tra file DLL có tồn tại không
$DllFiles = Get-ChildItem -Path $BinDir -Filter "*.dll" -ErrorAction SilentlyContinue
if (-not $DllFiles) {
    Write-Host "ERROR: No DLL files found in $BinDir" -ForegroundColor Red
    Write-Host "Please build the project first using: dotnet build or msbuild" -ForegroundColor Yellow
    exit 1
}

# Lấy file DLL mới nhất (theo thời gian tạo)
$LatestDll = $DllFiles | Sort-Object CreationTime -Descending | Select-Object -First 1
$DllName = $LatestDll.Name
$DllPath = $LatestDll.FullName

Write-Host "Found DLL: $DllName" -ForegroundColor Cyan
Write-Host "DLL Path: $DllPath" -ForegroundColor Cyan
Write-Host "DLL Size: $([math]::Round($LatestDll.Length / 1KB, 2)) KB" -ForegroundColor Cyan
Write-Host "Build Time: $($LatestDll.CreationTime)" -ForegroundColor Cyan
Write-Host ""

# Tạo thư mục đích nếu chưa tồn tại
if (-not (Test-Path $UserAddInsDir)) {
    New-Item -ItemType Directory -Path $UserAddInsDir -Force | Out-Null
    Write-Host "Created directory: $UserAddInsDir" -ForegroundColor Yellow
}

try {
    # Copy DLL file
    $DestDllPath = Join-Path $RevitAddInsDir $DllName
    Copy-Item $DllPath $DestDllPath -Force
    Write-Host "✓ Copied DLL to: $DestDllPath" -ForegroundColor Green
    
    # Copy .addin file
    $AddinFile = Get-ChildItem -Path $ProjectDir -Filter "*.addin" | Select-Object -First 1
    if ($AddinFile) {
        $DestAddinPath = Join-Path $UserAddInsDir $AddinFile.Name
        Copy-Item $AddinFile.FullName $DestAddinPath -Force
        Write-Host "✓ Copied .addin file to: $DestAddinPath" -ForegroundColor Green
        
        # Cập nhật đường dẫn DLL trong file .addin
        $AddinContent = Get-Content $DestAddinPath -Raw
        $AddinContent = $AddinContent -replace '<Assembly>.*?</Assembly>', "<Assembly>$DllName</Assembly>"
        Set-Content $DestAddinPath -Value $AddinContent -Encoding UTF8
        Write-Host "✓ Updated assembly path in .addin file" -ForegroundColor Green
    } else {
        Write-Host "WARNING: No .addin file found" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "=== Installation Complete ===" -ForegroundColor Green
    Write-Host "DLL installed to: $DestDllPath" -ForegroundColor White
    if ($AddinFile) {
        Write-Host "Manifest installed to: $DestAddinPath" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Close Revit if it's running" -ForegroundColor White
    Write-Host "2. Start Revit $RevitVersion" -ForegroundColor White
    Write-Host "3. Look for 'Cập nhật Pipe Endpoint' command in External Tools" -ForegroundColor White
    Write-Host "4. Use DebugView to monitor logs during execution" -ForegroundColor White
    Write-Host ""
    Write-Host "Log file location: $env:TEMP\PipeEndpointUpdater_$(Get-Date -Format 'yyyyMMdd').log" -ForegroundColor Cyan
    
} catch {
    Write-Host "ERROR: Failed to install add-in" -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    
    # Kiểm tra quyền Administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin) {
        Write-Host ""
        Write-Host "TIP: Try running as Administrator if you get permission errors" -ForegroundColor Yellow
        Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    }
    
    exit 1
}

# Hiển thị thông tin về các file đã cài đặt
Write-Host "=== Installed Files ===" -ForegroundColor Cyan
if (Test-Path $DestDllPath) {
    $DllInfo = Get-Item $DestDllPath
    Write-Host "DLL: $($DllInfo.FullName) ($(Get-Date $DllInfo.LastWriteTime -Format 'yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
}
if ($AddinFile -and (Test-Path $DestAddinPath)) {
    $AddinInfo = Get-Item $DestAddinPath
    Write-Host "ADDIN: $($AddinInfo.FullName) ($(Get-Date $AddinInfo.LastWriteTime -Format 'yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
}
Write-Host ""