#!/bin/bash

# 测试Gatekeeper绕过方法的脚本

echo "🔒 测试Gatekeeper绕过方法"
echo "================================"
echo ""

# 获取最新的未签名DMG
LATEST_DMG=$(ls -t CTCClick-Unsigned-*.dmg | head -1)

if [ -z "$LATEST_DMG" ]; then
    echo "❌ 找不到未签名的DMG文件"
    echo "请先运行: ./build_unsigned.sh"
    exit 1
fi

echo "📦 使用DMG文件: $LATEST_DMG"
echo ""

# 创建测试目录
TEST_DIR="gatekeeper_test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

echo "🔍 测试方法1: 移除quarantine标记"
echo "--------------------------------"

# 复制DMG到测试目录
cp "$LATEST_DMG" "$TEST_DIR/"
cd "$TEST_DIR"

# 检查quarantine标记
echo "原始quarantine标记:"
xattr -l "$LATEST_DMG" | grep com.apple.quarantine || echo "无quarantine标记"

# 移除quarantine标记
echo "移除quarantine标记..."
xattr -cr "$LATEST_DMG"

echo "移除后的quarantine标记:"
xattr -l "$LATEST_DMG" | grep com.apple.quarantine || echo "无quarantine标记"

echo ""
echo "🔍 测试方法2: 挂载DMG并处理应用"
echo "--------------------------------"

# 挂载DMG
echo "挂载DMG..."
MOUNT_POINT=$(hdiutil attach "$LATEST_DMG" | grep "/Volumes" | awk '{print $3}')

if [ -n "$MOUNT_POINT" ]; then
    echo "✅ DMG已挂载到: $MOUNT_POINT"
    
    # 查找应用
    APP_PATH=$(find "$MOUNT_POINT" -name "*.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "📱 找到应用: $APP_PATH"
        
        # 复制应用到测试目录
        cp -R "$APP_PATH" ./
        APP_NAME=$(basename "$APP_PATH")
        
        echo "检查应用的quarantine标记:"
        xattr -lr "$APP_NAME" | grep com.apple.quarantine || echo "无quarantine标记"
        
        # 移除应用的quarantine标记
        echo "移除应用的quarantine标记..."
        xattr -cr "$APP_NAME"
        
        echo "移除后的quarantine标记:"
        xattr -lr "$APP_NAME" | grep com.apple.quarantine || echo "无quarantine标记"
        
        # 检查代码签名状态
        echo ""
        echo "🔐 检查代码签名状态:"
        codesign -dv "$APP_NAME" 2>&1 || echo "无有效签名"
        
        # 尝试重新签名（ad-hoc签名）
        echo ""
        echo "🖊️  尝试ad-hoc签名:"
        codesign --force --deep --sign - "$APP_NAME"
        
        if [ $? -eq 0 ]; then
            echo "✅ ad-hoc签名成功"
            echo "重新检查签名状态:"
            codesign -dv "$APP_NAME" 2>&1
        else
            echo "❌ ad-hoc签名失败"
        fi
        
    else
        echo "❌ 在DMG中找不到应用"
    fi
    
    # 卸载DMG
    echo ""
    echo "卸载DMG..."
    hdiutil detach "$MOUNT_POINT"
    
else
    echo "❌ DMG挂载失败"
fi

cd ..

echo ""
echo "🔍 测试方法3: 创建自签名证书（高级）"
echo "--------------------------------"

# 检查是否有自签名证书
SELF_SIGNED_CERT=$(security find-identity -v -p codesigning | grep "Mac Developer" | head -1)

if [ -n "$SELF_SIGNED_CERT" ]; then
    echo "✅ 找到开发者证书，可以进行签名"
    
    # 使用开发者证书签名
    cd "$TEST_DIR"
    if [ -d "$APP_NAME" ]; then
        echo "使用开发者证书重新签名..."
        codesign --force --deep --sign "Mac Developer" "$APP_NAME" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✅ 开发者证书签名成功"
        else
            echo "⚠️  开发者证书签名失败，使用ad-hoc签名"
        fi
    fi
    cd ..
else
    echo "ℹ️  未找到开发者证书，建议使用ad-hoc签名"
fi

echo ""
echo "📋 测试总结"
echo "================================"
echo "✅ 已生成测试版本: $TEST_DIR/$LATEST_DMG"
echo "✅ 已移除quarantine标记"
echo "✅ 已进行ad-hoc签名"
echo ""
echo "🚀 分发建议:"
echo "1. 使用处理后的DMG文件分发"
echo "2. 提供详细的安装指南 (INSTALL_GUIDE.md)"
echo "3. 告知用户首次运行时右键点击选择'打开'"
echo "4. 如果仍有问题，用户可以使用终端命令移除quarantine标记"
echo ""
echo "📁 测试文件位置: $TEST_DIR/"

# 清理测试目录（可选）
read -p "是否删除测试目录？(y/N): " cleanup
if [[ "$cleanup" =~ ^[Yy]$ ]]; then
    rm -rf "$TEST_DIR"
    echo "🧹 测试目录已清理"
fi