//
//  ActionSettingsView.swift
//  CTCClick
//
//  Created by 李旭 on 2024/4/9.
//

import SwiftUI

struct ActionSettingsTabView: View {
    @EnvironmentObject var appState: AppState
    
    let messager = Messager.shared

    var body: some View {
        VStack(spacing: 16) {
            // 标题和重置按钮
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("操作功能管理")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("启用或禁用右键菜单中的操作功能")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    appState.resetActionItems()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 12, weight: .medium))
                        
                        Text("重置默认")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .orange.opacity(0.3), radius: 3, x: 0, y: 1)
                    )
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            // 操作列表
            if appState.actions.isEmpty {
                // 空状态
                VStack(spacing: 16) {
                    Image(systemName: "bolt.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    VStack(spacing: 6) {
                        Text("暂无操作功能")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("点击上方的\"重置默认\"按钮来恢复默认操作功能")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach($appState.actions) { $item in
                            ActionCardView(
                                action: item,
                                isEnabled: $item.enabled,
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
    }
}

struct ActionCardView: View {
    let action: RCAction
    @Binding var isEnabled: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
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
                
                Image(systemName: action.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isEnabled ? .primary : .secondary)
            }
            
            // 文本信息
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(action.name))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isEnabled ? .primary : .secondary)
                
                Text(getActionDescription(action.name))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // 开关
            Toggle("", isOn: $isEnabled)
                .scaleEffect(0.8)
                .onChange(of: isEnabled) { _ in
                    onToggle()
                }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(isEnabled ? 0.2 : 0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isEnabled ? 1.0 : 0.98)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
    
    private func getActionDescription(_ actionName: String) -> String {
        switch actionName {
        case "Copy Path":
            return "复制文件或文件夹的完整路径"
        case "Copy Name":
            return "复制文件或文件夹的名称"
        case "Open Terminal":
            return "在当前位置打开终端"
        case "Show Hidden Files":
            return "显示或隐藏隐藏文件"
        case "New File":
            return "在当前位置创建新文件"
        case "Delete to Trash":
            return "将文件移动到废纸篓"
        default:
            return "右键菜单操作功能"
        }
    }
}



#Preview {
    ActionSettingsTabView()
        .environmentObject(AppState())
}
