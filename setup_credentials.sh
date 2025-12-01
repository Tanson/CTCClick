#!/bin/bash

# 交互式公证凭据设置脚本

echo "🔐 设置Apple公证服务凭据"
echo "================================"
echo ""

# 检查是否已有凭据
if xcrun notarytool history --keychain-profile "notarytool-password" >/dev/null 2>&1; then
    echo "✅ 公证凭据已存在"
    echo "当前配置的凭据信息："
    xcrun notarytool history --keychain-profile "notarytool-password" | head -5
    echo ""
    read -p "是否要重新配置？(y/N): " reconfigure
    if [[ ! "$reconfigure" =~ ^[Yy]$ ]]; then
        echo "保持现有配置"
        exit 0
    fi
fi

echo "请按照以下步骤设置："
echo ""
echo "1. 首先需要生成App专用密码："
echo "   - 打开浏览器访问: https://appleid.apple.com"
echo "   - 登录你的Apple ID"
echo "   - 在'登录和安全'部分，点击'App专用密码'"
echo "   - 点击'生成密码'，标签可以设为'notarytool'"
echo "   - 复制生成的密码（格式类似：xxxx-xxxx-xxxx-xxxx）"
echo ""

read -p "请输入你的Apple ID邮箱: " apple_id
if [[ -z "$apple_id" ]]; then
    echo "❌ Apple ID不能为空"
    exit 1
fi

echo ""
echo "请输入刚才生成的App专用密码："
read -s app_password
if [[ -z "$app_password" ]]; then
    echo "❌ App专用密码不能为空"
    exit 1
fi

echo ""
echo "🔄 正在配置公证凭据..."

# 存储凭据到钥匙串
xcrun notarytool store-credentials "notarytool-password" \
    --apple-id "$apple_id" \
    --team-id "6LJD5Q2Z8J" \
    --password "$app_password"

if [ $? -eq 0 ]; then
    echo "✅ 公证凭据配置成功！"
    echo ""
    echo "验证配置："
    xcrun notarytool history --keychain-profile "notarytool-password" | head -5
    echo ""
    echo "现在可以运行构建脚本了："
    echo "  ./build_and_notarize.sh"
else
    echo "❌ 公证凭据配置失败"
    echo "请检查Apple ID和App专用密码是否正确"
    exit 1
fi