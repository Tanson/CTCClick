//
//  GeneralSettingsTabView.swift
//  CTCClick
//
//  Created by 李旭 on 2024/4/9.
//

import AppKit
import Cocoa
import FinderSync
import SwiftUI

struct GeneralSettingsTabView: View {
    @AppLog(category: "settings-general")
    private var logger

    @AppStorage("extensionEnabled") private var extensionEnabled = false
    @AppStorage(Key.showMenuBarExtra) private var showMenuBarExtra = true
    @AppStorage(Key.showInDock) private var showInDock = false
    @AppStorage(Key.showContextMenu) private var showContextMenu = true

    @EnvironmentObject var store: AppState

    @State private var showAlert = false
    @State private var wrongFold = false
    @State private var showDirImporter = false

    @Environment(\.scenePhase) private var scenePhase

    let messager = Messager.shared

    var enableIcon: String {
        if extensionEnabled {
            return "checkmark.circle.fill"
        } else {
            return "checkmark.circle"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 标题
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("通用设置")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("配置应用的基本设置和权限")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                VStack(spacing: 12) {
                    // 扩展状态卡片
                    SettingsCard(
                        title: "扩展状态",
                        subtitle: "CTCClick 扩展需要启用才能正常工作",
                        icon: "puzzlepiece.extension",
                        iconColor: extensionEnabled ? .green : .orange
                    ) {
                        VStack(spacing: 10) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: enableIcon)
                                        .foregroundColor(extensionEnabled ? .green : .orange)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text(extensionEnabled ? "扩展已启用" : "扩展未启用")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(extensionEnabled ? .green : .orange)
                                }
                                
                                Spacer()
                                
                                if !extensionEnabled {
                                    Button(action: openExtensionset) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "gear")
                                                .font(.system(size: 11))
                                            Text("打开设置")
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 1)
                                        )
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }
                    }
                    
                    // 启动设置卡片
                    SettingsCard(
                        title: "启动设置",
                        subtitle: "配置应用程序的启动行为",
                        icon: "power",
                        iconColor: .green
                    ) {
                        VStack(spacing: 8) {
                            LaunchAtLogin.Toggle(
                                LocalizedStringKey("开机自启动")
                            )
                        }
                    }
                    
                    // 界面显示卡片
                    SettingsCard(
                        title: "界面显示",
                        subtitle: "控制应用程序图标的显示位置",
                        icon: "display",
                        iconColor: .purple
                    ) {
                        VStack(spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("菜单栏显示")
                                        .font(.system(size: 13, weight: .medium))
                                    Text("在菜单栏显示 CTCClick 图标")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $showMenuBarExtra)
                                    .onChange(of: showMenuBarExtra) { newValue in
                                        logger.debug("Menu bar display changed: \(newValue)")
                                        // 当菜单栏显示和Dock显示都关闭时，自动启用右键菜单显示
                                        if !newValue && !showInDock {
                                            showContextMenu = true
                                        }
                                    }
                            }
                            
                            Divider()
                                .padding(.horizontal, -12)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Dock 显示")
                                        .font(.system(size: 13, weight: .medium))
                                    Text("在 Dock 中显示应用程序图标")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $showInDock)
                                    .onChange(of: showInDock) { newValue in
                                        logger.debug("Dock display changed: \(newValue)")
                                        if newValue {
                                            NSApp.setActivationPolicy(.regular)
                                        } else {
                                            NSApp.setActivationPolicy(.accessory)
                                        }
                                        // 当菜单栏显示和Dock显示都关闭时，自动启用右键菜单显示
                                        if !newValue && !showMenuBarExtra {
                                            showContextMenu = true
                                        }
                                    }
                            }
                            
                            Divider()
                                .padding(.horizontal, -12)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("右键菜单显示")
                                        .font(.system(size: 13, weight: .medium))
                                    Text("在右键菜单中显示设置选项")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $showContextMenu)
                                    .disabled(!showMenuBarExtra && !showInDock) // 当菜单栏和Dock都关闭时，禁用右键菜单的开关
                            }
                        }
                    }
                    
                    // 授权文件夹卡片
                    SettingsCard(
                        title: "授权文件夹",
                        subtitle: "只有在授权的文件夹中才能执行菜单操作",
                        icon: "folder.badge.gearshape",
                        iconColor: .indigo
                    ) {
                        VStack(spacing: 10) {
                            // 添加文件夹按钮
                            HStack {
                                Spacer()
                                
                                Button {
                                    showDirImporter = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "folder.badge.plus")
                                            .font(.system(size: 12))
                                        Text("添加文件夹")
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .shadow(color: .indigo.opacity(0.3), radius: 3, x: 0, y: 1)
                                    )
                                }
                                .buttonStyle(.borderless)
                            }
                            
                            // 文件夹列表
                            if store.dirs.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "folder.badge.questionmark")
                                        .font(.system(size: 24))
                                        .foregroundColor(.secondary.opacity(0.6))
                                    
                                    Text("暂无授权文件夹")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    Text("添加文件夹以启用右键菜单功能")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 12)
                            } else {
                                LazyVStack(spacing: 4) {
                                    ForEach(store.dirs) { item in
                                        FolderRow(
                                            folder: item,
                                            onRemove: { removeBookmark(item) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .alert(
            Text("无效的文件夹选择"),
            isPresented: $wrongFold
        ) {
            Button("确定") {
                showDirImporter = true
            }
        } message: {
            Text("所选文件夹是之前选择文件夹的子目录。请选择不同的文件夹。")
        }
        .alert(
            Text("未授权的文件夹"),
            isPresented: $showAlert
        ) {
            Button("确定") {
                showDirImporter = true
            }
        } message: {
            Text("您必须授予对文件夹的访问权限才能使用此功能。")
        }
        .fileImporter(
            isPresented: $showDirImporter,
            allowedContentTypes: [.directory],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let dirs):
                startAddDir(dirs.first!)
            case .failure(let error):
                logger.error("Failed to import directory: \(error)")
                print(error)
            }
        }
        .onAppear {
            extensionEnabled = FIFinderSyncController.isExtensionEnabled
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            updateEnableState()
        }
        .task {
            await checkPermissionFolder()
        }
    }

    func updateEnableState() {
        extensionEnabled = FIFinderSyncController.isExtensionEnabled
    }

    func checkPermissionFolder() async {
        for item in store.dirs {
            if !item.url.startAccessingSecurityScopedResource() {
                logger.warning("Failed to access security scoped resource: \(item.url)")
            }
        }
    }

    @MainActor
    func startAddDir(_ url: URL) {
        let isSubdirectory = store.dirs.contains { existingDir in
            url.path.hasPrefix(existingDir.url.path + "/")
        }
        
        if isSubdirectory {
            wrongFold = true
            return
        }
        
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            let permissiveDir = PermissiveDir(permUrl: url)
            store.dirs.append(permissiveDir)
            try? store.savePermissiveDir()
            messager.sendMessage(name: "running", data: MessagePayload(action: "running", target: []))
        } else {
            showAlert = true
        }
    }

    @MainActor private func removeBookmark(_ item: PermissiveDir) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = store.dirs.firstIndex(of: item) {
                store.deletePermissiveDir(index: index)
            }
            messager.sendMessage(name: "running", data: MessagePayload(action: "running", target: []))
        }
    }

    private func openExtensionset() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences")!)
    }
}

// 设置卡片组件
struct SettingsCard<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(title: String, subtitle: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 卡片标题
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // 卡片内容
            content
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// 文件夹行组件
struct FolderRow: View {
    let folder: PermissiveDir
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "folder.fill")
                .font(.system(size: 12))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(folder.url.lastPathComponent)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(folder.url.path)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundColor(.red)
                    .frame(width: 22, height: 22)
                    .background(
                        Circle()
                            .fill(.red.opacity(0.1))
                    )
            }
            .buttonStyle(.borderless)
            .help("删除文件夹")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.secondary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

#Preview {
    GeneralSettingsTabView()
        .environmentObject(AppState())
}
