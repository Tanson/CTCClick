#!/bin/bash

echo "🔧 CTCClick Finder扩展修复工具"
echo "================================"
echo ""

# 检查应用是否存在
if [ ! -d "/Applications/CTCClick.app" ]; then
    echo "❌ 未找到CTCClick应用，请先安装应用"
    exit 1
fi

# 检查扩展是否存在
FINDER_EXT_PATH="/Applications/CTCClick.app/Contents/PlugIns/FinderSyncExt.appex"
if [ ! -d "$FINDER_EXT_PATH" ]; then
    echo "❌ 未找到Finder扩展文件"
    exit 1
fi

echo "✅ 找到CTCClick应用和Finder扩展"
echo ""

# 步骤1：检查当前扩展状态
echo "🔍 步骤1：检查当前扩展状态..."
CURRENT_STATUS=$(pluginkit -m -v -i cn.tanson.CTCClick.FinderSyncExt 2>/dev/null)
if [ -z "$CURRENT_STATUS" ]; then
    echo "⚠️  扩展未在系统中注册"
else
    echo "ℹ️  当前扩展状态："
    echo "$CURRENT_STATUS"
fi
echo ""

# 步骤2：重新签名扩展
echo "🔧 步骤2：重新签名扩展..."
sudo codesign --force --deep --sign - "$FINDER_EXT_PATH" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ 扩展重新签名成功"
else
    echo "❌ 扩展签名失败，请检查权限"
    exit 1
fi
echo ""

# 步骤3：清理现有注册
echo "🧹 步骤3：清理现有扩展注册..."
pluginkit -r "$FINDER_EXT_PATH" 2>/dev/null
echo "✅ 已清理现有注册"
echo ""

# 步骤4：重新注册扩展
echo "📝 步骤4：重新注册扩展..."
pluginkit -a "$FINDER_EXT_PATH" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ 扩展注册成功"
else
    echo "❌ 扩展注册失败"
fi
echo ""

# 步骤5：启用扩展
echo "🔓 步骤5：启用扩展..."
pluginkit -e use -i cn.tanson.CTCClick.FinderSyncExt 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ 扩展启用命令执行成功"
else
    echo "❌ 扩展启用失败"
fi
echo ""

# 步骤6：重启相关服务
echo "🔄 步骤6：重启相关服务..."
echo "   - 重启Finder..."
killall Finder 2>/dev/null
sleep 2

echo "   - 重启pluginkit服务..."
sudo pkill -f pluginkit 2>/dev/null
sleep 1

echo "✅ 服务重启完成"
echo ""

# 步骤7：验证修复结果
echo "🔍 步骤7：验证修复结果..."
sleep 3
FINAL_STATUS=$(pluginkit -m -v -i cn.tanson.CTCClick.FinderSyncExt 2>/dev/null)
if [ -n "$FINAL_STATUS" ]; then
    echo "✅ 扩展修复成功！"
    echo "📋 扩展状态："
    echo "$FINAL_STATUS"
    echo ""
    echo "🎯 下一步操作："
    echo "1. 打开'系统偏好设置' > '扩展' > 'Finder扩展'"
    echo "2. 确保CTCClick已勾选"
    echo "3. 在Finder中右键点击文件测试功能"
else
    echo "⚠️  扩展仍未在系统中注册"
    echo ""
    echo "📋 可能的原因和解决方案："
    echo "1. macOS安全策略限制："
    echo "   - 打开'系统偏好设置' > '隐私与安全性'"
    echo "   - 查看是否有CTCClick相关的安全提示"
    echo "   - 点击'允许'按钮"
    echo ""
    echo "2. 需要完全重启："
    echo "   - 重启电脑以刷新系统扩展数据库"
    echo "   - 重启后再次运行此脚本"
    echo ""
    echo "3. 手动启用："
    echo "   - 打开'系统偏好设置' > '扩展' > 'Finder扩展'"
    echo "   - 查找并勾选CTCClick"
    echo "   - 如果没有看到，请重启电脑"
    echo ""
    echo "4. 权限问题："
    echo "   - 确保CTCClick在'隐私与安全性'中被允许运行"
    echo "   - 检查'完全磁盘访问权限'设置"
fi

echo ""
echo "🔧 修复脚本执行完成！"
echo ""
echo "💡 提示："
echo "• 如果问题仍然存在，请重启电脑后再试"
echo "• 某些macOS版本需要手动在系统偏好设置中启用扩展"
echo "• 确保应用本身可以正常运行"