//
//  NewFileSettingsTabView.swift
//  CTCClick
//
//  Created by 李旭 on 2024/11/18.
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct NewFileSettingsTabView: View {
    @AppLog(category: "NewFileSettingsTabView")
    private var logger
    
    @EnvironmentObject var appState: AppState
    @State private var editingFile: NewFile?
    @State private var showSelectApp = false
    
    // 编辑状态
    @State private var editingName: String = ""
    @State private var editingExt: String = ""
    @State private var editingIcon: String = "document"
    @State private var editingOpenApp: URL?
    // 添加状态变量
    @State private var editingTemplate: URL?
    @State private var showSelectTemplate = false
    
    // 新建状态
    @State private var isAddingNew = false
    
    let messager = Messager.shared
    // 优化后的存储路径选择
    let templatesDir: URL? = // 选项1: 应用程序支持目录（推荐）
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
        .appendingPathComponent("CTCClick/Templates")
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // 标题和按钮
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("新建文件管理")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("管理右键菜单中的新建文件类型")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            isAddingNew = true
                            editingFile = NewFile(ext: "", name: "", idx: appState.newFiles.count)
                            resetEditingFields()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .medium))
                                
                                Text("新增文件类型")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .frame(height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            appState.resetFiletypeItems()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 11, weight: .medium))
                                
                                Text("重置默认")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .frame(height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .shadow(color: .orange.opacity(0.3), radius: 2, x: 0, y: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // 文件列表或空状态
                if appState.newFiles.isEmpty {
                    // 空状态
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                        
                        VStack(spacing: 8) {
                            Text("暂无文件类型")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("点击上方的\"添加文件类型\"按钮来添加新的文件类型")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach($appState.newFiles) { $item in
                                NewFileCardView(
                                    file: item,
                                    isEnabled: $item.enabled,
                                    onEdit: {
                                         editingFile = item
                                         editingName = item.name
                                         editingExt = item.ext
                                         // 处理图标选择
                                         if let customIconPath = item.customIconPath {
                                             editingIcon = "custom:\(customIconPath)"
                                         } else {
                                             editingIcon = item.icon
                                         }
                                         editingOpenApp = item.openApp
                                         editingTemplate = item.template
                                     },
                                    onToggle: {
                                        appState.toggleActionItem()
                                        messager.sendMessage(name: "running", data: MessagePayload(action: "running", target: []))
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                }
            }
            
            // 编辑弹窗
            if editingFile != nil {
                // 背景遮罩
                Rectangle()
                    .fill(.black.opacity(0.4))
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        cancelEditing()
                    }
                
                VStack(spacing: 24) {
                    // 弹窗标题
                    HStack {
                        Text(isAddingNew ? "添加文件类型" : "编辑文件类型")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            cancelEditing()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .frame(width: 28, height: 28)
                                .background(
                                    Circle()
                                        .fill(.secondary.opacity(0.1))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("显示名称")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextField("文件类型显示名称", text: $editingName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("文件扩展名")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextField("例如：.txt", text: $editingExt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("文件图标")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            IconSelectorButton(selectedIcon: $editingIcon)
                        }
                        
                        // 模板选择
                        VStack(alignment: .leading, spacing: 8) {
                            Text("文件模板")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                if let templateUrl = editingTemplate {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.text")
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                        
                                        Text(templateUrl.lastPathComponent)
                                            .font(.system(size: 14))
                                            .foregroundColor(.primary)
                                        
                                        Button(action: {
                                            editingTemplate = nil
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.blue.opacity(0.1))
                                    )
                                }
                                
                                Button(action: {
                                    showSelectTemplate = true
                                }) {
                                    Text(editingTemplate == nil ? "选择模板" : "更换模板")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.blue, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.regularMaterial)
                        )
                        
                        // 默认打开应用
                        VStack(alignment: .leading, spacing: 8) {
                            Text("默认打开应用")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                if let appUrl = editingOpenApp {
                                    HStack(spacing: 8) {
                                        Image(nsImage: NSWorkspace.shared.icon(forFile: appUrl.path()))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                        
                                        Text(appUrl.lastPathComponent)
                                            .font(.system(size: 14))
                                            .foregroundColor(.primary)
                                        
                                        Button(action: {
                                            editingOpenApp = nil
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.green.opacity(0.1))
                                    )
                                }
                                
                                Button(action: {
                                    showSelectApp = true
                                }) {
                                    Text(editingOpenApp == nil ? "选择应用" : "更换应用")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.green, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.regularMaterial)
                        )
                    }
                    
                    // 操作按钮
                    HStack(spacing: 16) {
                        Button(action: {
                            cancelEditing()
                        }) {
                            Text("取消")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.secondary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .keyboardShortcut(.escape)
                        
                        Button(action: {
                            saveChanges()
                        }) {
                            Text(isAddingNew ? "添加" : "保存")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .keyboardShortcut(.return)
                        .disabled(editingName.isEmpty || editingExt.isEmpty)
                    }
                }
                .padding(24)
                .frame(width: 500)
                .frame(maxHeight: 600)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.thickMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.primary.opacity(0.1), lineWidth: 1)
                        )
                )
            }
        }
        .fileImporter(
            isPresented: $showSelectTemplate,
            allowedContentTypes: [.content],
            allowsMultipleSelection: false
        ) { result in
            logger.warning("start select template result")
            switch result {
            case .success(let files):
                if let url = files.first {
                    editingTemplate = url
                }
            case .failure:
                logger.warning("error when import template file")
            }
        }
        .fileImporter(
            isPresented: $showSelectApp,
            allowedContentTypes: [.application],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                if let url = files.first {
                    editingOpenApp = url
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    private func resetEditingFields() {
        editingName = ""
        editingExt = ""
        editingIcon = "document"
        editingOpenApp = nil
        editingTemplate = nil
    }
    
    private func cancelEditing() {
        editingFile = nil
        isAddingNew = false
    }
    
    private func saveChanges() {
        guard var file = editingFile else { return }
        
        file.name = editingName
        file.ext = editingExt
        file.icon = editingIcon
        file.openApp = editingOpenApp
        file.template = editingTemplate
        
        // 处理自定义图标路径
        if editingIcon.hasPrefix("custom:") {
            file.customIconPath = String(editingIcon.dropFirst(7)) // 移除 "custom:" 前缀
        } else {
            file.customIconPath = nil
        }
        
        if isAddingNew {
            appState.newFiles.append(file)
        } else {
            if let index = appState.newFiles.firstIndex(where: { $0.id == file.id }) {
                appState.newFiles[index] = file
            }
        }
        
        appState.toggleActionItem()
        messager.sendMessage(name: "running", data: MessagePayload(action: "running", target: []))
        
        cancelEditing()
    }
}

// 新建文件卡片视图
struct IconSelectorButton: View {
    @Binding var selectedIcon: String
    @State private var showingIconSelector = false
    
    var body: some View {
        Button(action: {
            showingIconSelector = true
        }) {
            HStack(spacing: 12) {
                // 当前选中的图标
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    if selectedIcon.starts(with: "custom:") {
                        let iconPath = String(selectedIcon.dropFirst(7))
                        if FileManager.default.fileExists(atPath: iconPath),
                           let nsImage = NSImage(contentsOfFile: iconPath) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "document")
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                        }
                    } else if selectedIcon.starts(with: "icon-") {
                        Image(selectedIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: selectedIcon)
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("点击选择图标")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(getIconDisplayName())
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingIconSelector) {
            IconSelectorPopover(selectedIcon: $selectedIcon, isPresented: $showingIconSelector)
        }
    }
    
    private func getIconDisplayName() -> String {
        if selectedIcon.starts(with: "custom:") {
            let iconPath = String(selectedIcon.dropFirst(7))
            return "自定义图标: \(URL(fileURLWithPath: iconPath).lastPathComponent)"
        } else if selectedIcon.starts(with: "icon-") {
            return "内置图标: \(selectedIcon)"
        } else {
            return "系统图标: \(selectedIcon)"
        }
    }
}

struct NewFileCardView: View {
    let file: NewFile
    @Binding var isEnabled: Bool
    let onEdit: () -> Void
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标区域
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        colors: isEnabled ? 
                            [.blue.opacity(0.1), .purple.opacity(0.1)] : 
                            [.secondary.opacity(0.05), .secondary.opacity(0.1)], 
                        startPoint: .topLeading, 
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                
                if let appUrl = file.openApp {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: appUrl.path()))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                } else {
                    if file.icon.starts(with: "icon-") {
                        Image(file.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                    } else if let customIconPath = file.customIconPath,
                              FileManager.default.fileExists(atPath: customIconPath) {
                        // 自定义图标
                        if let nsImage = NSImage(contentsOfFile: customIconPath) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        } else {
                            // 如果自定义图标加载失败，显示默认图标
                            Image(systemName: "document")
                                .font(.system(size: 16))
                                .foregroundColor(isEnabled ? .primary : .secondary)
                        }
                    } else {
                        Image(systemName: file.icon)
                            .font(.system(size: 16))
                            .foregroundColor(isEnabled ? .primary : .secondary)
                    }
                }
            }
            
            // 文件信息
            VStack(alignment: .leading, spacing: 3) {
                Text(file.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isEnabled ? .primary : .secondary)
                
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Text("扩展名：")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(file.ext)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    if let templateUrl = file.template {
                        HStack(spacing: 2) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 10))
                                .foregroundColor(.blue)
                            Text("模板：\(templateUrl.lastPathComponent)")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Spacer()
            
            // 操作按钮
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(.blue.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .help("编辑文件类型")
                
                Toggle("", isOn: $isEnabled)
                    .onChange(of: isEnabled) { _ in
                        onToggle()
                    }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary.opacity(isEnabled ? 0.15 : 0.08), lineWidth: 1)
                )
        )
        .scaleEffect(isEnabled ? 1.0 : 0.98)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}



#Preview {
    NewFileSettingsTabView()
        .environmentObject(AppState())
}
