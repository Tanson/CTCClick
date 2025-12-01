#!/bin/bash

# CTCClick Finder扩展启用脚本

echo "🔧 CTCClick Finder扩展启用工具"
echo "================================"
echo ""

# 检查CTCClick应用是否存在
if [ ! -d "/Applications/CTCClick.app" ]; then
    echo "❌ 错误：未找到CTCClick应用"
    echo "请确保CTCClick.app已安装在/Applications目录中"
    exit 1
fi

# 检查Finder扩展是否存在
EXTENSION_PATH="/Applications/CTCClick.app/Contents/PlugIns/FinderSyncExt.appex"
if [ ! -d "$EXTENSION_PATH" ]; then
    echo "❌ 错误：未找到Finder扩展"
    echo "扩展路径：$EXTENSION_PATH"
    exit 1
fi

echo "✅ 找到CTCClick应用和Finder扩展"
echo ""

echo "🔍 检查当前扩展状态..."
CURRENT_EXTENSIONS=$(pluginkit -m -v | grep -i -E "(ctc|tanson)" || true)

if [ -z "$CURRENT_EXTENSIONS" ]; then
    echo "ℹ️  当前没有注册的CTCClick扩展"
else
    echo "📋 当前已注册的扩展："
    echo "$CURRENT_EXTENSIONS"
    echo ""
fi

echo "🔧 开始启用Finder扩展..."

# 步骤1：对扩展进行临时签名
echo "1. 对Finder扩展进行临时签名..."
codesign --force --deep --sign - "$EXTENSION_PATH" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ 扩展签名成功"
else
    echo "   ⚠️  扩展签名失败，但继续尝试..."
fi

# 步骤2：移除现有的扩展注册（如果存在）
echo "2. 清理现有扩展注册..."
pluginkit -r "$EXTENSION_PATH" 2>/dev/null || true
echo "   ✅ 已清理现有注册"

# 步骤3：重新注册扩展
echo "3. 注册Finder扩展..."
pluginkit -a "$EXTENSION_PATH"
if [ $? -eq 0 ]; then
    echo "   ✅ 扩展注册成功"
else
    echo "   ❌ 扩展注册失败"
fi

# 步骤4：启用扩展
echo "4. 启用Finder扩展..."
pluginkit -e use -i cn.tanson.CTCClick.FinderSyncExt 2>/dev/null || true
echo "   ✅ 已尝试启用扩展"

# 步骤5：重启Finder
echo "5. 重启Finder以应用更改..."
killall Finder 2>/dev/null || true
sleep 2
echo "   ✅ Finder已重启"

echo ""
echo "🔍 验证扩展状态..."

# 等待系统更新扩展状态
sleep 3

# 检查扩展是否已注册
REGISTERED_EXTENSIONS=$(pluginkit -m -v | grep -i -E "(ctc|tanson)" || true)

if [ -z "$REGISTERED_EXTENSIONS" ]; then
    echo "⚠️  扩展未在系统中注册"
    echo ""
    echo "📋 可能的原因和解决方案："
    echo "1. macOS安全策略阻止了未签名扩展"
    echo "2. 需要在'系统偏好设置 > 扩展 > Finder扩展'中手动启用"
    echo "3. 需要在'系统偏好设置 > 隐私与安全性'中允许扩展"
    echo ""
    echo "🔧 手动启用步骤："
    echo "1. 打开'系统偏好设置'"
    echo "2. 进入'扩展' > 'Finder扩展'"
    echo "3. 查找并勾选'CTCClick'"
    echo "4. 如果没有看到CTCClick，请重启电脑后再试"
else
    echo "✅ 扩展已成功注册："
    echo "$REGISTERED_EXTENSIONS"
    echo ""
    echo "🎉 Finder扩展启用完成！"
    echo ""
    echo "📋 使用说明："
    echo "1. 在Finder中右键点击文件或文件夹"
    echo "2. 查看是否出现CTCClick相关菜单项"
    echo "3. 如果没有看到，请检查'系统偏好设置 > 扩展 > Finder扩展'"
fi

echo ""
echo "🔄 重要提醒："
echo "• 如果扩展仍未工作，请重启电脑"
echo "• 某些macOS版本可能需要手动在系统偏好设置中启用"
echo "• 确保在'隐私与安全性'中允许CTCClick运行"
echo ""
echo "🎯 完成！"