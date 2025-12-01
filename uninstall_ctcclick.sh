#!/bin/bash

# CTCClick 完全卸载脚本

echo "🗑️  CTCClick 完全卸载工具"
echo "================================"
echo ""

# 检查是否以管理员权限运行
if [[ $EUID -eq 0 ]]; then
   echo "⚠️  请不要以root权限运行此脚本"
   echo "请使用普通用户权限运行: ./uninstall_ctcclick.sh"
   exit 1
fi

echo "此脚本将完全删除CTCClick应用及其所有相关文件和授权"
echo ""
read -p "确定要继续吗？(y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "取消卸载"
    exit 0
fi

echo ""
echo "🔍 开始卸载CTCClick..."

# 1. 停止应用进程
echo "1. 停止CTCClick进程..."
pkill -f "CTCClick" 2>/dev/null || echo "   没有运行中的CTCClick进程"

# 2. 删除主应用
echo "2. 删除主应用..."
if [ -d "/Applications/CTCClick.app" ]; then
    rm -rf "/Applications/CTCClick.app"
    echo "   ✅ 已删除 /Applications/CTCClick.app"
else
    echo "   ℹ️  /Applications/CTCClick.app 不存在"
fi

# 3. 删除用户数据目录
echo "3. 删除用户数据..."
USER_DATA_DIRS=(
    "$HOME/Library/Application Support/CTCClick"
    "$HOME/Library/Application Support/cn.tanson.CTCClick"
    "$HOME/Library/Caches/CTCClick"
    "$HOME/Library/Caches/cn.tanson.CTCClick"
    "$HOME/Library/WebKit/CTCClick"
    "$HOME/Library/WebKit/cn.tanson.CTCClick"
)

for dir in "${USER_DATA_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        echo "   ✅ 已删除 $dir"
    fi
done

# 4. 删除偏好设置文件
echo "4. 删除偏好设置..."
PREF_FILES=(
    "$HOME/Library/Preferences/CTCClick.plist"
    "$HOME/Library/Preferences/cn.tanson.CTCClick.plist"
    "$HOME/Library/Preferences/cn.tanson.CTCClick.FinderSyncExt.plist"
)

for pref in "${PREF_FILES[@]}"; do
    if [ -f "$pref" ]; then
        rm -f "$pref"
        echo "   ✅ 已删除 $pref"
    fi
done

# 5. 删除日志文件
echo "5. 删除日志文件..."
LOG_DIRS=(
    "$HOME/Library/Logs/CTCClick"
    "$HOME/Library/Logs/cn.tanson.CTCClick"
)

for log_dir in "${LOG_DIRS[@]}"; do
    if [ -d "$log_dir" ]; then
        rm -rf "$log_dir"
        echo "   ✅ 已删除 $log_dir"
    fi
done

# 6. 删除Finder扩展相关
echo "6. 删除Finder扩展..."
# 重置Finder扩展
pluginkit -r "$HOME/Library/Application Support/CTCClick" 2>/dev/null || true
pluginkit -r "/Applications/CTCClick.app" 2>/dev/null || true

# 7. 删除启动项
echo "7. 删除启动项..."
LAUNCH_AGENTS=(
    "$HOME/Library/LaunchAgents/cn.tanson.CTCClick.plist"
    "$HOME/Library/LaunchAgents/CTCClick.plist"
)

for agent in "${LAUNCH_AGENTS[@]}"; do
    if [ -f "$agent" ]; then
        launchctl unload "$agent" 2>/dev/null || true
        rm -f "$agent"
        echo "   ✅ 已删除启动项 $agent"
    fi
done

# 8. 清理系统扩展授权
echo "8. 清理系统扩展授权..."
echo "   正在重置系统扩展..."

# 重置所有相关的系统扩展
sudo pluginkit -r /Applications/CTCClick.app 2>/dev/null || true
sudo pluginkit -r "$HOME/Library/Application Support/CTCClick" 2>/dev/null || true

# 查找并删除所有CTCClick相关的扩展
echo "   查找并清理CTCClick相关扩展..."
CTCCLICK_EXTENSIONS=$(pluginkit -m -v 2>/dev/null | grep -i -E "(ctc|tanson)" | awk '{print $1}' | cut -d'(' -f1 || true)

if [ ! -z "$CTCCLICK_EXTENSIONS" ]; then
    echo "   发现CTCClick相关扩展，正在清理..."
    while IFS= read -r extension; do
        if [ ! -z "$extension" ]; then
            echo "   - 移除扩展: $extension"
            sudo pluginkit -r "$extension" 2>/dev/null || true
            pluginkit -r "$extension" 2>/dev/null || true
        fi
    done <<< "$CTCCLICK_EXTENSIONS"
else
    echo "   ✅ 没有发现CTCClick相关扩展"
fi

# 强制刷新扩展数据库
echo "   刷新扩展数据库..."
sudo pluginkit -R 2>/dev/null || true

# 清理LaunchServices数据库中的CTCClick条目
echo "   清理LaunchServices数据库..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user 2>/dev/null || true

# 9. 清理钥匙串中的相关项目
echo "9. 清理钥匙串..."
security delete-generic-password -s "CTCClick" 2>/dev/null || echo "   没有找到CTCClick相关的钥匙串项目"

# 10. 重启Finder和相关服务
echo "10. 重启相关服务..."
echo "    重启Finder..."
killall Finder 2>/dev/null || true

echo "    重启系统扩展服务..."
sudo launchctl kickstart -k system/com.apple.pluginkit.pkd 2>/dev/null || true

# 11. 清理临时文件
echo "11. 清理临时文件..."
TEMP_DIRS=(
    "/tmp/CTCClick*"
    "/tmp/cn.tanson.CTCClick*"
    "$HOME/Library/Saved Application State/cn.tanson.CTCClick.savedState"
)

for temp in "${TEMP_DIRS[@]}"; do
    rm -rf $temp 2>/dev/null || true
done

echo "   ✅ 已清理临时文件"

# 12. 验证卸载结果
echo ""
echo "🔍 验证卸载结果..."

REMAINING_FILES=()

# 检查主要位置是否还有残留
CHECK_LOCATIONS=(
    "/Applications/CTCClick.app"
    "$HOME/Library/Application Support/CTCClick"
    "$HOME/Library/Application Support/cn.tanson.CTCClick"
    "$HOME/Library/Preferences/cn.tanson.CTCClick.plist"
)

for location in "${CHECK_LOCATIONS[@]}"; do
    if [ -e "$location" ]; then
        REMAINING_FILES+=("$location")
    fi
done

# 检查是否还有CTCClick相关的扩展
REMAINING_EXTENSIONS=$(pluginkit -m -v 2>/dev/null | grep -i -E "(ctc|tanson)" || true)

if [ ${#REMAINING_FILES[@]} -eq 0 ] && [ -z "$REMAINING_EXTENSIONS" ]; then
    echo "✅ 卸载完成！没有发现残留文件和扩展"
else
    if [ ${#REMAINING_FILES[@]} -gt 0 ]; then
        echo "⚠️  发现以下残留文件："
        for file in "${REMAINING_FILES[@]}"; do
            echo "   - $file"
        done
    fi
    
    if [ ! -z "$REMAINING_EXTENSIONS" ]; then
        echo "⚠️  发现以下残留扩展："
        echo "$REMAINING_EXTENSIONS" | while IFS= read -r line; do
            echo "   - $line"
        done
    fi
    
    echo ""
    echo "如需手动删除，请运行："
    for file in "${REMAINING_FILES[@]}"; do
        echo "   sudo rm -rf '$file'"
    done
    
    if [ ! -z "$REMAINING_EXTENSIONS" ]; then
        echo ""
        echo "如需手动删除扩展，请在'系统偏好设置 > 扩展'中手动禁用"
    fi
fi

echo ""
echo "📋 卸载总结"
echo "================================"
echo "✅ 已停止所有CTCClick进程"
echo "✅ 已删除主应用程序"
echo "✅ 已删除用户数据和偏好设置"
echo "✅ 已删除日志文件"
echo "✅ 已删除Finder扩展"
echo "✅ 已删除启动项"
echo "✅ 已清理系统扩展授权和数据库"
echo "✅ 已重启相关系统服务"
echo ""
echo "🔄 建议操作："
echo "1. 重启电脑以确保所有更改生效"
echo "2. 检查'系统偏好设置 > 扩展 > Finder扩展'确认CTCClick已被移除"
echo "3. 检查'系统偏好设置 > 隐私与安全性'确认相关授权已被清除"
echo "4. 如果仍有残留扩展，请手动在系统偏好设置中禁用"
echo ""
echo "🎉 CTCClick卸载完成！"