# CTCClick - macOS访达右键菜单增强工具

## 📋 项目简介

CTCClick是一款专为macOS设计的访达（Finder）右键菜单增强工具，通过Finder扩展技术为用户的文件管理体验提供强大的自定义功能。该应用允许用户自定义右键菜单，快速创建各类文件、使用指定应用打开文件夹、执行常用文件操作等，大大提升工作效率。

项目采用Apache 2.0开源协议，完全开源透明，用户可自由查看源码、自行编译或进行二次开发。

## ✨ 功能特性

### 🎯 核心功能

1. **自定义右键菜单**
   - 支持在访达右键菜单中添加自定义选项
   - 可配置菜单项的显示顺序和图标
   - 支持多级子菜单结构

2. **快速文件创建**
   - 支持创建多种常用文件类型（TXT、Markdown、JSON、Office文档等）
   - 内置文件模板，可自定义文件模板
   - 智能文件名生成，避免重复

3. **应用快速启动**
   - 使用指定应用快速打开当前文件夹
   - 支持VSCode、终端等常用开发工具
   - 可自定义添加其他应用程序

4. **常用文件夹管理**
   - 添加常用文件夹到右键菜单
   - 一键快速访问常用目录
   - 支持文件夹图标自定义

5. **实用文件操作**
   - 复制文件/文件夹路径
   - 快速删除文件（绕过废纸篓）
   - 文件/文件夹隐藏与显示
   - AirDrop快速分享文件

### 🔧 高级功能

1. **权限管理**
   - 支持macOS安全书签机制
   - 访问系统保护文件夹时自动提醒
   - 细粒度的文件系统权限控制

2. **国际化支持**
   - 支持中英文双语界面
   - 基于系统语言自动切换

3. **扩展管理**
   - 独立运行的Finder扩展
   - 与主应用通过消息机制通信
   - 支持扩展的自动启用和修复

## 🛠 技术栈

### 开发环境
- **操作系统**: macOS 11.0+
- **开发工具**: Xcode 13.0+
- **编程语言**: Swift 5.5+
- **UI框架**: SwiftUI + AppKit

### 核心技术
- **FinderSync框架**: 实现访达右键菜单扩展
- **安全书签**: macOS文件系统权限管理
- **进程间通信**: 主应用与扩展间的消息传递
- **用户偏好存储**: UserDefaults数据持久化
- **应用沙盒**: 符合macOS安全要求

### 依赖框架
- AppKit.framework - macOS应用框架
- FinderSync.framework - 访达扩展框架
- SwiftUI.framework - 现代化UI框架
- Foundation.framework - 基础系统服务

## 📁 项目结构

```
CTCClick/
├── CTCClick/                    # 主应用代码
│   ├── CTCClickApp.swift       # 应用主入口
│   ├── AppState.swift          # 全局状态管理
│   ├── MenuBarView.swift       # 菜单栏界面
│   ├── Model/                  # 数据模型
│   │   └── RCBase.swift        # 基础数据结构和协议
│   ├── Settings/               # 设置界面
│   │   ├── SettingsView.swift  # 主设置界面
│   │   ├── GeneralSettingsTabView.swift    # 通用设置
│   │   ├── ActionSettingsTabView.swift     # 动作设置
│   │   ├── AppsSettingsTabView.swift       # 应用设置
│   │   ├── NewFileSettingsTabView.swift    # 新建文件设置
│   │   ├── CommonDirsSettingTabView.swift  # 常用文件夹设置
│   │   └── AboutSettingsTabView.swift      # 关于页面
│   ├── Shared/                 # 共享工具
│   │   ├── Utils.swift         # 工具函数
│   │   ├── Constants.swift   # 常量定义
│   │   ├── Messager.swift    # 消息通信
│   │   ├── AppLogger.swift   # 日志系统
│   │   └── Extension+.swift  # 扩展方法
│   ├── Assets.xcassets/        # 应用资源
│   │   ├── AppIcon.appiconset/ # 应用图标
│   │   ├── icon-file-*/        # 文件类型图标
│   │   └── MenuBar.imageset/  # 菜单栏图标
│   ├── Resources/              # 模板文件
│   │   └── template.xlsx      # Excel模板
│   └── Info.plist             # 应用配置
├── FinderSyncExt/              # Finder扩展
│   ├── FinderSyncExt.swift   # 扩展主逻辑
│   ├── MenuItemClickable.swift # 菜单项协议
│   └── Info.plist             # 扩展配置
├── CTCClick.xcodeproj/        # Xcode项目文件
├── build_*.sh                  # 构建脚本
├── enable_finder_extension.sh # 扩展启用脚本
├── fix_finder_extension.sh    # 扩展修复脚本
├── INSTALL_GUIDE.md           # 安装指南
├── BUILD_FROM_SOURCE.md       # 源码构建指南
├── DISTRIBUTION_GUIDE.md     # 分发指南
└── LICENSE                    # Apache 2.0许可证
```

## 🚀 运行与构建

### 环境要求
- macOS 11.0 Big Sur 或更高版本
- Xcode 13.0 或更高版本
- Swift 5.5 或更高版本

### 快速构建
```bash
# 使用未签名构建脚本（推荐）
./build_unsigned.sh

# 或使用Xcode构建
xcodebuild clean build -project CTCClick.xcodeproj -scheme CTCClick -configuration Release
```

### 详细构建步骤
1. **克隆项目**
   ```bash
   git clone [项目地址]
   cd CTCClick
   ```

2. **打开项目**
   ```bash
   open CTCClick.xcodeproj
   ```

3. **配置签名（可选）**
   - 有开发者账户：选择开发团队
   - 无开发者账户：选择"Sign to Run Locally"

4. **构建应用**
   - 使用Xcode GUI：Product > Archive
   - 或使用命令行：参考BUILD_FROM_SOURCE.md

### 安装与启用
1. **安装应用**
   - 将构建的CTCClick.app拖拽到Applications文件夹

2. **启用Finder扩展**
   ```bash
   # 运行启用脚本
   chmod +x enable_finder_extension.sh
   ./enable_finder_extension.sh
   ```

3. **首次运行**
   - 右键点击应用选择"打开"
   - 在系统偏好设置中启用扩展

## 🏗 架构模块

### 应用架构
```
┌─────────────────────────────────────────────────────────────┐
│                    用户界面层                                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   设置界面   │ │   菜单栏     │ │   关于页面   │          │
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘          │
│         │               │               │                  │
│  ───────┼───────────────┼───────────────┼──────            │
│         │               │               │                  │
│  ┌──────┴──────┐ ┌──────┴──────┐ ┌──────┴──────┐          │
│  │  SwiftUI    │ │  AppKit     │ │  SwiftUI    │          │
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘          │
└─────────┼───────────────┼───────────────┼────────────────┘
          │               │               │
          └───────────────┼───────────────┼────────────────────┘
                        │               │
┌───────────────────────┼───────────────┼────────────────────┐
│                       │   业务逻辑层    │                    │
│  ┌─────────────┐ ┌────┴──────┐ ┌─────┴──────┐               │
│  │   AppState   │ │ 数据模型   │ │  工具函数   │               │
│  │  (状态管理)  │ │ (RCBase)  │ │  (Utils)   │               │
│  └──────┬──────┘ └─────┬─────┘ └──────┬─────┘               │
│         │              │              │                     │
│  ───────┼──────────────┼──────────────┼─────                │
│         │              │              │                     │
│  ┌──────┴──────┐ ┌─────┴──────┐ ┌─────┴──────┐              │
│  │  数据持久化  │ │  消息通信   │ │  权限管理   │              │
│  │ (UserDefaults)│ │ (Messager) │ │ (Bookmark) │              │
│  └──────┬──────┘ └─────┬─────┘ └──────┬─────┘              │
└─────────┼──────────────┼──────────────┼─────────────────────┘
          │              │              │
          └──────────────┼──────────────┼─────────────────────┘
                         │              │
┌────────────────────────┼──────────────┼─────────────────────┐
│                        │  系统服务层   │                    │
│  ┌─────────────┐ ┌─────┴──────┐ ┌─────┴──────┐              │
│  │ Finder扩展  │ │  文件系统   │ │  系统服务   │              │
│  │(FinderSync) │ │ (FileManager)│ │ (NSWorkspace)│              │
│  └─────────────┘ └────────────┘ └────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

### 核心模块说明

1. **AppState模块**
   - 全局状态管理中心
   - 管理应用、文件夹、动作等数据
   - 负责数据持久化和同步

2. **FinderSyncExt模块**
   - 访达扩展实现
   - 右键菜单动态生成
   - 与主应用的消息通信

3. **Settings模块**
   - 用户界面配置
   - 功能开关控制
   - 数据绑定和验证

4. **Model模块**
   - 数据模型定义
   - 协议和接口规范
   - 数据验证和转换

5. **Shared模块**
   - 工具函数集合
   - 常量定义
   - 扩展方法

## ⚙️ 配置与环境

### 应用配置
- **Bundle ID**: `cn.tanson.CTCClick`
- **最低系统要求**: macOS 11.0
- **架构支持**: x86_64, arm64 (Apple Silicon)

### 权限配置
- **文件访问**: 通过安全书签机制
- **扩展权限**: Finder扩展权限
- **沙盒权限**: 符合macOS安全要求

### 用户配置
- **配置文件**: `~/Library/Preferences/cn.tanson.CTCClick.plist`
- **应用数据**: `~/Library/Application Support/CTCClick`
- **缓存文件**: `~/Library/Caches/cn.tanson.CTCClick`

## ❓ 常见问题

### Q1: 应用无法打开，提示"已损坏"
**解决方案:**
```bash
sudo xattr -cr /Applications/CTCClick.app
sudo codesign --force --deep --sign - /Applications/CTCClick.app
```

### Q2: Finder扩展不工作
**解决方案:**
```bash
# 运行修复脚本
chmod +x fix_finder_extension.sh
./fix_finder_extension.sh

# 重启Finder
killall Finder
```

### Q3: 右键菜单没有显示
**可能原因:**
- 扩展未启用：检查系统偏好设置 > 扩展
- 权限问题：重新授权文件访问权限
- 系统缓存：重启电脑

### Q4: 如何卸载应用
```bash
# 删除应用
rm -rf /Applications/CTCClick.app

# 清理用户数据（可选）
rm -rf ~/Library/Application\ Support/CTCClick
rm -rf ~/Library/Preferences/cn.tanson.CTCClick.plist

# 重启Finder
killall Finder
```

### Q5: 构建失败怎么办
**检查项:**
- Xcode版本是否符合要求
- 是否选择了正确的签名配置
- 依赖框架是否完整
- 查看详细构建日志

## 📈 发展规划

### 近期计划 (v1.1)
- [ ] 增加更多文件类型模板
- [ ] 支持自定义菜单图标
- [ ] 添加文件批量操作功能
- [ ] 优化扩展启用流程

### 中期计划 (v1.2)
- [ ] 支持云存储服务集成
- [ ] 添加文件预览功能
- [ ] 支持自定义脚本执行
- [ ] 增加主题定制选项

### 长期愿景 (v2.0)
- [ ] 支持插件系统
- [ ] 跨平台支持（Windows、Linux）
- [ ] AI智能文件管理
- [ ] 企业级权限管理

## 🤝 贡献指南

### 如何贡献
1. Fork 项目仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

### 开发规范
- 遵循Swift编码规范
- 添加必要的注释和文档
- 编写单元测试
- 确保代码通过静态分析

## 📞 联系方式

- **项目维护**: 李旭
- **创建时间**: 2024年4月
- **许可证**: Apache License 2.0
- **问题反馈**: 通过GitHub Issues

## 📄 许可证

本项目采用 Apache License 2.0 开源协议 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

**⭐ 如果这个项目对你有帮助，请给个Star支持一下！**