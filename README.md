# Pipe Endpoint Updater - Revit MEP Add-in

## Mô tả
Add-in Revit MEP này cho phép cập nhật endpoint của ống dựa trên connector của đối tượng khác tron### Troubleshooting với Debug Logs

#### Lỗi thường gặp và cách debug
1. **"Không chọn được ống"**: 
   - Check log: `SelectionHelper.cs SelectPipe()`
   - Verify selection filter working

2. **"Không tìm thấy connector"**: 
   - Check log: `ConnectorHelper.cs GetAvailableConnector()`
   - Verify target element has connectors

3. **"Không thể cập nhật endpoint"**: 
   - Check log: `PipeHelper.cs UpdatePipeEndpoint()`
   - Verify transaction state và geometry constraints

#### Debug workflow
1. **Enable debug mode**: Build với Debug configuration
2. **Start DebugView**: Mở DebugView trước khi test
3. **Run add-in**: Execute command trong Revit
4. **Analyze logs**: Xem detailed execution flow
5. **Check log file**: Review saved logs nếu cần

#### Performance monitoring
- Log entry/exit của methods quan trọng
- Timing information cho các operations
- Memory usage tracking (nếu cần)

### Advanced Debug Features

#### Custom log levels
```csharp
Logger.LogDebug("Debug info chỉ xuất hiện trong debug build");
Logger.LogInfo("Thông tin chung");
Logger.LogWarning("Cảnh báo");
Logger.LogError("Lỗi");
Logger.LogException(ex, "Context information");
```

#### Method tracing
```csharp
Logger.LogMethodEntry("MethodName", param1, param2);
// ... method code ...
Logger.LogMethodExit("MethodName", returnValue);
```

#### Revit environment info
- Machine name, user name
- OS version, CLR version  
- Revit process ID
- Assembly location
## Chức năng chính
1. **Chọn ống cần cập nhật**: Người dùng chọn ống muốn thay đổi endpoint
2. **Chọn đối tượng target**: Chọn đối tượng (pipe/fitting/equipment) có connector để làm endpoint mới
3. **Cập nhật tự động**: Add-in sẽ tự động cập nhật endpoint của ống để kết nối với connector đã chọn

## Debug và Logging

### Debug Logging System
Add-in đã được tích hợp debug logging system để giúp troubleshoot các vấn đề:

#### Xem logs qua DebugView
1. **Download DebugView**: Tải DebugView từ Microsoft Sysinternals
2. **Chạy DebugView**: Mở DebugView với quyền Administrator
3. **Enable logging**: 
   - Capture > Capture Win32 (check)
   - Capture > Capture Global Win32 (check)
4. **Filter logs**: Sử dụng filter `*PipeEndpointUpdater*` để chỉ xem logs của add-in

#### Xem logs qua file
- **Vị trí**: `%TEMP%\PipeEndpointUpdater_YYYYMMDD.log`
- **Format**: `YYYY-MM-DD HH:mm:ss.fff [LEVEL] [PipeEndpointUpdater] File:Line Method() - Message`
- **Levels**: DEBUG, INFO, WARNING, ERROR, EXCEPTION

#### Log file example:
```
2024-09-17 14:30:15.123 [INFO] [PipeEndpointUpdater] UpdatePipeEndpointCommand.cs:25 Execute() - Document: Project1.rvt, PathName: C:\Projects\Project1.rvt
2024-09-17 14:30:16.456 [DEBUG] [PipeEndpointUpdater] SelectionHelper.cs:34 SelectPipe() - Creating pipe selection filter
2024-09-17 14:30:20.789 [INFO] [PipeEndpointUpdater] SelectionHelper.cs:42 SelectPipe() - User selected pipe: ID=123456, Name=Pipe
```

## Build và Development

### Build với Visual Studio Code 2022

#### Quick Build
1. **Sử dụng batch file**:
   ```cmd
   build.bat
   ```

2. **Sử dụng VS Code tasks**:
   - `Ctrl+Shift+P` → "Tasks: Run Task"
   - Chọn "build-debug" hoặc "build-release"

3. **Command line**:
   ```cmd
   dotnet build PipeEndpointUpdater.csproj /p:Configuration=Debug
   ```

#### Advanced Build Options
- **Build with timestamp**: `msbuild /p:AssemblyNameSuffix=20240917_143000`
- **Clean build**: `dotnet clean` sau đó `dotnet build`
- **Release build**: `/p:Configuration=Release`

### Auto-Installation Script
```powershell
# Build và install tự động
powershell -ExecutionPolicy Bypass -File install-to-revit.ps1

# Hoặc với custom configuration
powershell -ExecutionPolicy Bypass -File install-to-revit.ps1 -Configuration Release -RevitVersion 2024
```

### File Output với Timestamp
- **Format DLL**: `PipeEndpointUpdater_YYYYMMDD_HHMMSS.dll`
- **Example**: `PipeEndpointUpdater_20240917_143025.dll`
- **Vị trí**: `bin\Debug\` hoặc `bin\Release\`

### VS Code Integration

#### Available Tasks
- `build-debug`: Build debug version
- `build-release`: Build release version  
- `clean`: Clean build artifacts
- `rebuild`: Clean + build
- `install-to-revit`: Build + copy to Revit

#### Debugging
1. **Attach to Revit**:
   - Start Revit first
   - F5 → "Debug with Revit"
   - Set breakpoints in code

2. **Launch Revit**:
   - F5 → "Debug with Revit (Auto-attach)"
   - VS Code sẽ build và launch Revit

### Build Environment Requirements
- **.NET Framework 4.8**
- **MSBuild** (có trong Visual Studio Build Tools)
- **Revit 2023 SDK** (đường dẫn API references)
- **PowerShell 5.0+** (cho installation scripts)

## Sử dụng

### Khởi động command
1. Mở Revit
2. Tìm command "Cập nhật Pipe Endpoint" trong Ribbon hoặc External Tools
3. Click để khởi động

### Quy trình sử dụng
1. **Bước 1**: Click vào command, hệ thống sẽ yêu cầu chọn ống cần cập nhật
2. **Bước 2**: Click chọn ống trong model (chỉ có thể chọn Pipe objects)
3. **Bước 3**: Hệ thống yêu cầu chọn đối tượng target có connector
4. **Bước 4**: Click chọn đối tượng target (pipe, fitting, equipment có connector)
5. **Bước 5**: Add-in tự động cập nhật endpoint và hiển thị kết quả

## Cấu trúc Code

### Commands/
- `UpdatePipeEndpointCommand.cs`: Class chính implement IExternalCommand

### Helpers/
- `SelectionHelper.cs`: Hỗ trợ selection UI với filters
- `ConnectorHelper.cs`: Làm việc với connectors của MEP elements  
- `PipeHelper.cs`: Logic cập nhật endpoint của pipes

### Files khác
- `PipeEndpointUpdater.csproj`: Project file
- `PipeEndpointUpdater.addin`: Manifest file cho Revit
- `Properties/AssemblyInfo.cs`: Assembly information

## Các phương pháp cập nhật endpoint

Add-in sử dụng 3 phương pháp khác nhau để cập nhật endpoint (theo thứ tự ưu tiên):

1. **Pipe.Create**: Tạo pipe mới từ connector hiện tại đến target
2. **Element.Move**: Di chuyển toàn bộ pipe đến vị trí mới
3. **Location Curve**: Cập nhật geometry thông qua location curve

## Lưu ý kỹ thuật

### Compatibility
- Add-in hỗ trợ các loại MEP elements:
  - Pipes
  - Fittings (PipeFitting, DuctFitting)
  - Equipment (MechanicalEquipment, PlumbingFixtures)
  - Ducts (nếu cần mở rộng)

### Error Handling
- Validation input elements
- Transaction rollback nếu có lỗi
- User-friendly error messages

### Performance
- Efficient connector finding algorithms
- Minimal API calls
- Proper resource disposal

## Troubleshooting

### Lỗi thường gặp
1. **"Không chọn được ống"**: Đảm bảo đã chọn đúng Pipe object
2. **"Không tìm thấy connector"**: Target object phải có connector khả dụng
3. **"Không thể cập nhật endpoint"**: Kiểm tra quyền edit và geometry constraints

### Debug
- Kiểm tra Revit journal file để xem chi tiết lỗi
- Sử dụng TaskDialog.Show() để hiển thị thông tin debug
- Kiểm tra transaction state

## Phát triển thêm

### Tính năng có thể bổ sung
- Batch update multiple pipes
- Undo/Redo support
- Preview mode trước khi commit
- Advanced connector matching rules
- Integration với Ribbon UI

### Customization
- Modify selection filters trong SelectionHelper
- Thêm validation rules trong PipeHelper
- Customize error messages và UI text

## License
Sử dụng cho mục đích học tập và phát triển.

## Contact
Liên hệ để được hỗ trợ kỹ thuật hoặc báo cáo lỗi.