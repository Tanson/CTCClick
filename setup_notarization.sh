#!/bin/bash

# 公证设置脚本
# 用于配置Apple公证服务

echo "🔐 设置Apple公证服务..."

echo ""
echo "请按照以下步骤设置公证："
echo ""
echo "1. 生成App专用密码："
echo "   - 访问 https://appleid.apple.com"
echo "   - 登录你的Apple ID"
echo "   - 在'登录和安全'部分，点击'App专用密码'"
echo "   - 生成一个新的App专用密码，标签可以设为'notarytool'"
echo ""
echo "2. 将密码存储到钥匙串："
echo "   xcrun notarytool store-credentials \"notarytool-password\" \\"
echo "     --apple-id \"你的Apple ID邮箱\" \\"
echo "     --team-id \"6LJD5Q2Z8J\" \\"
echo "     --password \"刚才生成的App专用密码\""
echo ""
echo "3. 验证配置："
echo "   xcrun notarytool history --keychain-profile \"notarytool-password\""
echo ""
echo "完成设置后，就可以运行 ./build_and_notarize.sh 来构建和公证应用了。"
echo ""
echo "📝 注意事项："
echo "- 公证需要有效的Developer ID证书"
echo "- 应用必须使用Hardened Runtime"
echo "- 公证过程可能需要几分钟到几小时"
echo "- 只有公证过的应用才能在其他Mac上正常运行"