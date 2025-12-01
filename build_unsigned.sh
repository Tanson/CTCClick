#!/bin/bash

# 未签名版本构建脚本 - 适用于非付费Apple开发者账户

echo "🔨 构建未签名版本的CTCClick应用"
echo "================================"
echo ""

# 设置变量
PROJECT_NAME="CTCClick"
SCHEME_NAME="CTCClick"
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR/Export"
DMG_NAME="CTCClick-Unsigned-$(date +%Y%m%d-%H%M%S).dmg"

# 清理之前的构建
echo "🧹 清理之前的构建..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 构建Archive
echo "📦 创建Archive..."
xcodebuild archive \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

if [ $? -ne 0 ]; then
    echo "❌ Archive创建失败"
    exit 1
fi

echo "✅ Archive创建成功"

# 导出应用
echo "📤 导出应用..."
mkdir -p "$EXPORT_PATH"

# 创建导出配置文件
cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist"

if [ $? -ne 0 ]; then
    echo "❌ 应用导出失败"
    exit 1
fi

echo "✅ 应用导出成功"

# 查找导出的应用
APP_PATH=$(find "$EXPORT_PATH" -name "*.app" -type d | head -1)
if [ -z "$APP_PATH" ]; then
    echo "❌ 找不到导出的应用"
    exit 1
fi

echo "📍 应用路径: $APP_PATH"

# 移除扩展属性（quarantine标记）
echo "🔓 移除quarantine标记..."
xattr -cr "$APP_PATH"

# 对Finder扩展进行临时签名以确保其能被系统识别
echo "🔧 对Finder扩展进行临时签名..."
FINDER_EXT_PATH="$APP_PATH/Contents/PlugIns/FinderSyncExt.appex"
if [ -d "$FINDER_EXT_PATH" ]; then
    codesign --force --deep --sign - "$FINDER_EXT_PATH" 2>/dev/null || true
    echo "✅ Finder扩展已签名"
else
    echo "⚠️  未找到Finder扩展"
fi

# 创建DMG安装包
echo "💿 创建DMG安装包..."

# 创建临时目录用于DMG内容
DMG_TEMP_DIR="$BUILD_DIR/dmg_temp"
rm -rf "$DMG_TEMP_DIR"
mkdir -p "$DMG_TEMP_DIR"

# 复制应用到临时目录
cp -R "$APP_PATH" "$DMG_TEMP_DIR/"

# 创建Applications文件夹的符号链接
echo "🔗 创建Applications链接..."
ln -s /Applications "$DMG_TEMP_DIR/Applications"

# 创建DMG
hdiutil create -volname "$PROJECT_NAME" \
    -srcfolder "$DMG_TEMP_DIR" \
    -ov -format UDZO \
    "$DMG_NAME"

if [ $? -eq 0 ]; then
    echo "✅ DMG创建成功: $DMG_NAME"
    
    # 清理临时目录
    rm -rf "$DMG_TEMP_DIR"
    
    # 显示文件信息
    echo ""
    echo "📊 文件信息:"
    ls -lh "$DMG_NAME"
    
    # 移除quarantine标记
    echo "🔓 移除DMG的quarantine标记..."
    xattr -cr "$DMG_NAME"
    
    echo ""
    echo "🎉 构建完成！"
    echo "📦 DMG文件：$DMG_NAME"
    echo "📍 位置：$(pwd)/$DMG_NAME"
    echo ""
    echo "📋 分发说明："
    echo "1. 将DMG文件发送给用户"
    echo "2. 用户双击打开DMG，将CTCClick拖拽到Applications文件夹"
    echo "3. 首次启动时右键点击应用选择'打开'"
    echo "4. 运行以下脚本启用Finder扩展："
    echo "   ./enable_finder_extension.sh"
    echo "5. 或手动在'系统偏好设置 > 扩展 > Finder扩展'中启用CTCClick"
    echo ""
    echo "⚠️  重要提醒："
    echo "• 未签名应用的Finder扩展需要额外步骤才能启用"
    echo "• 建议提供enable_finder_extension.sh脚本给用户"
    echo "• 某些macOS版本可能需要重启电脑才能看到扩展"
    
else
    echo "❌ DMG创建失败"
    # 清理临时目录
    rm -rf "$DMG_TEMP_DIR"
    exit 1
fi