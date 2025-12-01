#!/bin/bash

# CTCClick 构建和公证脚本
# 用于创建可在其他Mac上运行的分发版本

set -e

# 配置变量
APP_NAME="CTCClick"
BUNDLE_ID="cn.tanson.CTCClick"
DEVELOPER_ID="Apple Development: tansenen@icloud.com (T4N8WFS4AQ)"
TEAM_ID="6LJD5Q2Z8J"
BUILD_DIR="build/Release"
ARCHIVE_PATH="build/${APP_NAME}.xcarchive"
EXPORT_PATH="build/Export"
DMG_NAME="${APP_NAME}-$(date +%Y%m%d-%H%M%S)"

echo "🚀 开始构建 ${APP_NAME}..."

# 清理之前的构建
echo "🧹 清理之前的构建..."
rm -rf build/
mkdir -p build

# 构建项目
echo "🔨 构建项目..."
xcodebuild -project CTCClick.xcodeproj \
    -scheme CTCClick \
    -configuration Release \
    -archivePath "${ARCHIVE_PATH}" \
    archive

# 导出应用
echo "📦 导出应用..."
cat > build/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${EXPORT_PATH}" \
    -exportOptionsPlist build/ExportOptions.plist

# 验证代码签名
echo "✅ 验证代码签名..."
APP_PATH="${EXPORT_PATH}/${APP_NAME}.app"
codesign --verify --verbose=2 "${APP_PATH}"
spctl --assess --verbose=2 "${APP_PATH}"

# 创建DMG
echo "💿 创建DMG安装包..."
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${EXPORT_PATH}" \
    -ov -format UDZO \
    "build/${DMG_NAME}.dmg"

echo "✨ 构建完成！"
echo "📍 应用位置: ${APP_PATH}"
echo "📍 DMG位置: build/${DMG_NAME}.dmg"

# 显示下一步操作提示
echo ""
echo "📋 下一步操作："
echo "1. 如果要分发给其他用户，需要进行公证："
echo "   xcrun notarytool submit build/${DMG_NAME}.dmg --keychain-profile \"notarytool-password\" --wait"
echo ""
echo "2. 公证完成后，装订票据："
echo "   xcrun stapler staple build/${DMG_NAME}.dmg"
echo ""
echo "3. 验证公证状态："
echo "   xcrun stapler validate build/${DMG_NAME}.dmg"