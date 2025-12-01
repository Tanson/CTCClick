#!/bin/bash

# CTCClick DMG制作脚本 - 使用已编译的应用
# 作者: tanson
# 日期: $(date +%Y-%m-%d)

set -e

echo "📦 CTCClick DMG制作工具"
echo "========================"
echo ""

# 配置变量
PROJECT_NAME="CTCClick"
SOURCE_APP_PATH="/Users/tanson/Desktop/开发/访达右键菜单/CTCClick 2025-10-29 02-01-16/CTCClick.app"
BUILD_DIR="$(pwd)/dmg_build"
DMG_NAME="${PROJECT_NAME}-$(date +%Y%m%d-%H%M%S).dmg"

# 检查源应用是否存在
if [ ! -d "$SOURCE_APP_PATH" ]; then
    echo "❌ 未找到源应用: $SOURCE_APP_PATH"
    exit 1
fi

echo "✅ 找到源应用: $SOURCE_APP_PATH"

# 检查Finder扩展是否存在
FINDER_EXT_PATH="$SOURCE_APP_PATH/Contents/PlugIns/FinderSyncExt.appex"
if [ ! -d "$FINDER_EXT_PATH" ]; then
    echo "❌ 未找到Finder扩展"
    exit 1
fi

echo "✅ 找到Finder扩展"
echo ""

# 创建构建目录
echo "🔧 准备构建环境..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 创建DMG临时目录
DMG_TEMP_DIR="$BUILD_DIR/dmg_temp"
mkdir -p "$DMG_TEMP_DIR"

echo "✅ 构建环境准备完成"
echo ""

# 复制应用到临时目录
echo "📋 复制应用文件..."
cp -R "$SOURCE_APP_PATH" "$DMG_TEMP_DIR/"
echo "✅ 应用文件复制完成"
echo ""

# 移除扩展属性（quarantine标记）
echo "🔓 移除quarantine标记..."
xattr -cr "$DMG_TEMP_DIR/CTCClick.app" 2>/dev/null || true
echo "✅ quarantine标记已移除"
echo ""

# 对Finder扩展进行临时签名以确保其能被系统识别
echo "🔧 对Finder扩展进行临时签名..."
TEMP_FINDER_EXT_PATH="$DMG_TEMP_DIR/CTCClick.app/Contents/PlugIns/FinderSyncExt.appex"
if [ -d "$TEMP_FINDER_EXT_PATH" ]; then
    codesign --force --deep --sign - "$TEMP_FINDER_EXT_PATH" 2>/dev/null || true
    echo "✅ Finder扩展已签名"
else
    echo "⚠️  未找到Finder扩展"
fi
echo ""

# 创建Applications文件夹的符号链接
echo "🔗 创建Applications链接..."
ln -s /Applications "$DMG_TEMP_DIR/Applications"
echo "✅ Applications链接创建完成"
echo ""

# 创建DMG
echo "💿 创建DMG安装包..."
hdiutil create -volname "$PROJECT_NAME" \
    -srcfolder "$DMG_TEMP_DIR" \
    -ov -format UDZO \
    "$DMG_NAME"

if [ $? -eq 0 ]; then
    echo "✅ DMG创建成功: $DMG_NAME"
    
    # 清理临时目录
    echo "🧹 清理临时文件..."
    rm -rf "$BUILD_DIR"
    echo "✅ 清理完成"
    
    echo ""
    echo "🎉 DMG制作完成！"
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
    echo "• 已编译应用的Finder扩展可能需要额外步骤才能启用"
    echo "• 建议提供enable_finder_extension.sh脚本给用户"
    echo "• 某些macOS版本可能需要重启电脑才能看到扩展"
    echo ""
    echo "🔧 如果扩展无法启用，请运行："
    echo "   ./fix_finder_extension.sh"
    
else
    echo "❌ DMG创建失败"
    rm -rf "$BUILD_DIR"
    exit 1
fi