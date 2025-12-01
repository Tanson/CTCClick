# 从源码构建 CTCClick

## 📋 概述

如果您不信任预编译的版本，或者想要自定义应用，可以从源码自行构建CTCClick。

## 🛠 环境要求

- **macOS**: 11.0 或更高版本
- **Xcode**: 13.0 或更高版本
- **Swift**: 5.5 或更高版本

## 📥 获取源码

### 方法一：Git克隆（如果有Git仓库）
```bash
git clone [仓库地址]
cd CTCClick
```

### 方法二：直接获取源码包
- 获取完整的项目文件夹
- 确保包含所有 `.swift` 文件和资源文件

## 🔨 构建步骤

### 1. 打开项目
```bash
# 进入项目目录
cd /path/to/CTCClick

# 打开Xcode项目
open CTCClick.xcodeproj
```

### 2. 配置签名（可选）

如果您有Apple开发者账户：
1. 在Xcode中选择项目
2. 在"Signing & Capabilities"中选择您的开发团队
3. 确保Bundle Identifier是唯一的

如果没有开发者账户：
1. 将"Automatically manage signing"取消勾选
2. 在"Signing Certificate"中选择"Sign to Run Locally"

### 3. 构建应用

#### 方法A：使用Xcode GUI
1. 选择"Product" > "Archive"
2. 等待构建完成
3. 在Organizer中选择"Distribute App"
4. 选择"Copy App"

#### 方法B：使用命令行
```bash
# 清理之前的构建
xcodebuild clean -project CTCClick.xcodeproj -scheme CTCClick

# 构建Release版本
xcodebuild archive \
    -project CTCClick.xcodeproj \
    -scheme CTCClick \
    -configuration Release \
    -archivePath build/CTCClick.xcarchive \
    -destination "generic/platform=macOS"

# 导出应用
xcodebuild -exportArchive \
    -archivePath build/CTCClick.xcarchive \
    -exportPath build/Export \
    -exportOptionsPlist ExportOptions.plist
```

### 4. 创建导出配置文件

创建 `ExportOptions.plist`：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
```

## 🚀 使用构建脚本

我们提供了自动化构建脚本：

### 未签名版本（推荐）
```bash
./build_unsigned.sh
```

### 签名版本（需要开发者账户）
```bash
./build_and_notarize.sh
```

## 🔧 自定义构建

### 修改应用信息
编辑 `CTCClick/Info.plist`：
- `CFBundleName`: 应用显示名称
- `CFBundleIdentifier`: Bundle ID
- `CFBundleVersion`: 版本号

### 修改图标
替换 `CTCClick/Assets.xcassets/AppIcon.appiconset/` 中的图标文件

### 添加功能
- 编辑 `.swift` 文件添加新功能
- 修改 `CTCClick.entitlements` 添加新权限

## 📦 打包分发

### 创建DMG
```bash
# 使用内置工具
hdiutil create -volname "CTCClick" \
    -srcfolder "build/Export/CTCClick.app" \
    -ov -format UDZO \
    "CTCClick-Custom.dmg"
```

### 创建ZIP
```bash
cd build/Export
zip -r CTCClick-Custom.zip CTCClick.app
```

## 🐛 常见问题

### 构建失败：缺少依赖
确保所有必要的框架都已链接：
- `AppKit.framework`
- `FinderSync.framework`
- `SwiftUI.framework`

### 签名错误
```bash
# 重置签名
codesign --force --deep --sign - build/Export/CTCClick.app
```

### 权限问题
检查 `CTCClick.entitlements` 和 `FinderSyncExt.entitlements` 文件是否正确配置

## 🔍 调试

### 查看构建日志
```bash
# 详细构建日志
xcodebuild -project CTCClick.xcodeproj \
    -scheme CTCClick \
    -configuration Debug \
    build | xcpretty
```

### 运行测试
```bash
xcodebuild test \
    -project CTCClick.xcodeproj \
    -scheme CTCClick \
    -destination "platform=macOS"
```

## 📝 贡献代码

如果您想要贡献代码：

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 创建Pull Request

## 🔒 安全注意事项

- 从源码构建的应用同样需要用户手动允许运行
- 建议在构建前检查源码，确保没有恶意代码
- 如果分发给他人，建议提供源码以供验证

---

**提示：** 如果您经常需要构建，建议设置持续集成(CI)来自动化这个过程。