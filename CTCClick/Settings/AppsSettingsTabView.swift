//
//  AppsSettingsTabView.swift
//  CTCClick
//
//  Created by 李旭 on 2024/4/4.
//

import SwiftUI
import Foundation
import AppKit

struct AppsSettingsTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var isImporting = false
    @State private var selectedApp: OpenWithApp?
    @State private var showingEditSheet = false
    @State private var expandedApps: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 页面标题
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("应用程序管理")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("添加和管理右键菜单中的应用程序")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isImporting = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 12))
                            
                            Text("添加应用")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 3, x: 0, y: 1)
                        )
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // 应用列表
                if appState.apps.isEmpty {
                    // 空状态
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.1),
                                            Color.purple.opacity(0.1),
                                            Color.cyan.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "app.dashed")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text("暂无应用程序")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("点击上方的\"添加应用\"按钮来添加您的第一个应用程序\n您可以添加任何 macOS 应用程序到右键菜单中")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(1)
                        }
                        
                        Button(action: {
                            isImporting = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 12))
                                
                                Text("立即添加应用")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.borderless)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                } else {
                    LazyVStack(spacing: 6) {
                        ForEach(appState.apps) { app in
                            AppCardView(
                                app: app,
                                isExpanded: expandedApps.contains(app.id),
                                onToggleExpand: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if expandedApps.contains(app.id) {
                                            expandedApps.remove(app.id)
                                        } else {
                                            expandedApps.insert(app.id)
                                        }
                                    }
                                },
                                onEdit: {
                                    selectedApp = app
                                    showingEditSheet = true
                                },
                                onDelete: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if let index = appState.apps.firstIndex(of: app) {
                                            appState.deleteApp(index: index)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 16)
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.application],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    let newApp = OpenWithApp(appURL: url)
                    appState.addApp(item: newApp)
                }
            case .failure(let error):
                print("Error importing app: \(error)")
            }
        }
        .sheet(item: $selectedApp) { (app: OpenWithApp) in
            AppEditSheet(app: app) { updatedApp in
                appState.updateApp(id: updatedApp.id, itemName: updatedApp.itemName, arguments: updatedApp.arguments, environment: updatedApp.environment)
            }
        }
    }
}

struct AppCardView: View {
    let app: OpenWithApp
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 主要内容
            HStack(spacing: 12) {
                // 应用图标
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.15),
                                    Color.purple.opacity(0.15),
                                    Color.cyan.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    let icon = NSWorkspace.shared.icon(forFile: app.url.path)
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0.5)
                }
                
                // 应用信息
                VStack(alignment: .leading, spacing: 3) {
                    Text(app.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(app.url.path)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                Spacer()
                
                // 操作按钮
                HStack(spacing: 6) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 24, height: 24)
                            )
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 24, height: 24)
                            )
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: onToggleExpand) {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 24, height: 24)
                            )
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(12)
            
            // 展开内容
            if isExpanded {
                VStack(spacing: 12) {
                    Rectangle()
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 1)
                        .padding(.horizontal, 12)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        if !app.arguments.isEmpty {
                            DetailRow(
                                title: "启动参数",
                                content: app.arguments.joined(separator: " "),
                                icon: "terminal.fill",
                                color: .orange
                            )
                        }
                        
                        if !app.environment.isEmpty {
                            DetailRow(
                                title: "环境变量",
                                content: AppEditSheet.formatEnvs(app.environment),
                                icon: "gearshape.fill",
                                color: .green
                            )
                        }
                        
                        DetailRow(
                            title: "完整路径",
                            content: app.url.path,
                            icon: "folder.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

struct DetailRow: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 16, height: 16)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color.opacity(0.15))
                    )
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text(content)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.secondary.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary.opacity(0.04), lineWidth: 1)
                        )
                )
        }
    }
}

struct AppEditSheet: View {
    let app: OpenWithApp
    let onSave: (OpenWithApp) -> Void
    
    @State private var displayName: String
    @State private var arguments: String
    @State private var envs: String
    @Environment(\.dismiss) private var dismiss
    
    init(app: OpenWithApp, onSave: @escaping (OpenWithApp) -> Void) {
        self.app = app
        self.onSave = onSave
        self._displayName = State(initialValue: app.itemName)
        self._arguments = State(initialValue: app.arguments.joined(separator: " "))
        self._envs = State(initialValue: Self.formatEnvs(app.environment))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            contentView
            footerView
        }
        .frame(width: 500, height: 600)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("编辑应用程序")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("修改应用程序的显示名称和启动参数")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
        }
        .padding(24)
        .background(
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    Rectangle()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                appInfoView
                formFieldsView
            }
            .padding(24)
        }
    }
    
    private var appInfoView: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                let icon = NSWorkspace.shared.icon(forFile: app.url.path)
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(app.url.path)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.secondary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
    }
    
    private var formFieldsView: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("显示名称")
                    .font(.headline)
                    .foregroundColor(.primary)
                TextField("输入显示名称", text: $displayName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("启动参数")
                    .font(.headline)
                    .foregroundColor(.primary)
                TextField("输入启动参数（可选）", text: $arguments)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("环境变量")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $envs)
                        .font(.system(size: 13, design: .monospaced))
                        .frame(height: 100)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text("格式：KEY=VALUE，每行一个")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var footerView: some View {
        HStack(spacing: 12) {
            Button("取消") {
                dismiss()
            }
            .buttonStyle(.borderless)
            .foregroundColor(.secondary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
            )
            
            Button("保存更改") {
                let envsDict = parseEnvs(envs)
                let argumentsArray = arguments.split(separator: " ").map(String.init)
                var updatedApp = app
                updatedApp.itemName = displayName
                updatedApp.arguments = argumentsArray
                updatedApp.environment = envsDict
                onSave(updatedApp)
                dismiss()
            }
            .buttonStyle(.borderless)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
            )
        }
        .padding(24)
        .background(
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    Rectangle()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 1),
                    alignment: .top
                )
        )
    }

    private func parseEnvs(_ envString: String) -> [String: String] {
        var result: [String: String] = [:]
        let lines = envString.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty && trimmed.contains("=") {
                let parts = trimmed.split(separator: "=", maxSplits: 1)
                if parts.count == 2 {
                    result[String(parts[0])] = String(parts[1])
                }
            }
        }
        return result
    }
    
    static func formatEnvs(_ envs: [String: String]) -> String {
        return envs.map { "\($0.key)=\($0.value)" }.joined(separator: "\n")
    }
}



#Preview {
    AppsSettingsTabView()
        .environmentObject(AppState())
}
