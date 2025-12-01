# CTCClick 安装指南

## 📋 概述

由于此应用未经过Apple公证，在其他Mac上安装时需要一些额外步骤。本指南将帮助用户安全地安装和运行CTCClick应用。

## 🔧 安装步骤

### 方法一：推荐方法（最简单）

1. **下载DMG文件**
   - 获取 `CTCClick-Unsigned-*.dmg` 文件

2. **打开DMG并拖拽安装**
   - 双击DMG文件打开
   - 将CTCClick.app拖拽到Applications文件夹（DMG中已包含Applications快捷方式）

3. **首次运行**
   - 在Applications文件夹中找到CTCClick
   - **右键点击** CTCClick.app，选择"打开"
   - 在弹出的对话框中点击"打开"

4. **启用Finder扩展**
   - 下载并运行 `enable_finder_extension.sh` 脚本：
     ```bash
     chmod +x enable_finder_extension.sh
     ./enable_finder_extension.sh
     ```
   - 或手动在"系统偏好设置" > "扩展" > "Finder扩展"中勾选CTCClick
   - 如果看不到CTCClick选项，请重启电脑后再试

### 方法二：使用终端（如果方法一不行）

1. **打开终端**
   - 按 `Cmd + 空格`，输入"终端"并回车

2. **移除quarantine标记**
   ```bash
   # 进入Applications目录
   cd /Applications
   
   # 移除quarantine标记
   sudo xattr -cr CTCClick.app
   ```

3. **运行应用**
   - 现在可以正常双击运行应用

### 方法三：系统偏好设置允许

1. **尝试运行应用**
   - 双击CTCClick.app

2. **如果出现安全警告**
   - 打开"系统偏好设置" > "安全性与隐私"
   - 在"通用"标签页底部，点击"仍要打开"

## ⚠️ 重要提醒：Finder扩展

**未签名应用的特殊说明：**

由于此应用未经Apple公证，Finder扩展需要额外的启用步骤：

1. **应用本身可以正常运行**，但Finder扩展（右键菜单功能）需要手动启用
2. **推荐使用提供的 `enable_finder_extension.sh` 脚本**自动处理扩展启用
3. **某些macOS版本**可能需要重启电脑才能看到扩展选项
4. **如果扩展仍不工作**，请检查"系统偏好设置" > "隐私与安全性"中的权限设置

## ⚠️ 安全说明

- 此应用未经Apple公证，但源码完全开放
- 应用不会收集任何个人信息
- 所有操作都在本地进行
- 如有安全顾虑，可以查看源码或自行编译

## 🔍 故障排除

### 问题1：应用无法打开，提示"已损坏"

**解决方案：**
```bash
# 在终端中运行
sudo xattr -cr /Applications/CTCClick.app
sudo codesign --force --deep --sign - /Applications/CTCClick.app
```

### 问题2：Finder扩展不工作

**解决方案：**

**自动方法（推荐）：**
```bash
# 下载并运行扩展启用脚本
chmod +x enable_finder_extension.sh
./enable_finder_extension.sh
```

**手动方法：**
1. 打开"系统偏好设置" > "扩展"
2. 在左侧选择"Finder扩展"
3. 确保CTCClick已勾选
4. 如果没有看到CTCClick选项：
   - 重启电脑
   - 检查"隐私与安全性"中是否允许CTCClick运行
   - 尝试重新安装应用

**高级解决方案：**
```bash
# 手动签名和注册扩展
sudo codesign --force --deep --sign - "/Applications/CTCClick.app/Contents/PlugIns/FinderSyncExt.appex"
pluginkit -a "/Applications/CTCClick.app/Contents/PlugIns/FinderSyncExt.appex"
pluginkit -e use -i cn.tanson.CTCClick.FinderSyncExt
killall Finder
```

### 问题3：右键菜单没有出现

**解决方案：**
1. 重启Finder：
   ```bash
   killall Finder
   ```
2. 或者注销并重新登录

### 问题4：macOS Ventura/Sonoma上的额外步骤

在较新的macOS版本上，可能需要：

1. **允许系统扩展**
   - 系统设置 > 隐私与安全性 > 系统扩展
   - 允许CTCClick的扩展

2. **授予完全磁盘访问权限**（如果需要）
   - 系统设置 > 隐私与安全性 > 完全磁盘访问权限
   - 添加CTCClick

## 📞 获取帮助

如果遇到问题：

1. **检查系统版本兼容性**
   - 支持macOS 11.0及以上版本

2. **查看控制台日志**
   - 打开"控制台"应用
   - 搜索"CTCClick"查看错误信息

3. **重新安装**
   - 删除旧版本：`rm -rf /Applications/CTCClick.app`
   - 重新按照步骤安装

## 🔄 卸载

如需卸载应用：

```bash
# 删除应用
rm -rf /Applications/CTCClick.app

# 清理用户数据（可选）
rm -rf ~/Library/Application\ Support/CTCClick
rm -rf ~/Library/Preferences/cn.tanson.CTCClick.plist

# 重启Finder
killall Finder
```

## 📝 版本说明

- 此为未签名版本，适用于个人使用
- 功能与签名版本完全相同
- 定期更新，请关注新版本发布

---

**注意：** 如果您是开发者且有付费Apple开发者账户，建议使用签名版本以获得更好的用户体验。