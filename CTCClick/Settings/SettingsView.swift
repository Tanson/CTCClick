//
//  SettingsView.swift
//  CTCClick
//
//  Created by 李旭 on 2024/4/4.
//

import SwiftUI

enum Tabs: String, CaseIterable, Identifiable {
    case general = "General"
    case apps = "Apps"
    case actions = "Actions"
    case newFile = "New File"
    case cdirs = "Common Dir"
    case about = "About"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .general: "slider.horizontal.2.square"
        case .apps: "apps.ipad.landscape"
        case .actions: "bolt.square"
        case .newFile: "doc.badge.plus"
        case .cdirs: "folder.badge.gearshape"
        case .about: "exclamationmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .general: .blue
        case .apps: .purple
        case .actions: .orange
        case .newFile: .green
        case .cdirs: .indigo
        case .about: .gray
        }
    }
}

struct SettingsView: View {
    @State private var selectedTab: Tabs = .general
    @EnvironmentObject var appState: AppState
    @State var showSelectApp = false
    @Environment(\.colorScheme) var colorScheme

    @ViewBuilder
    private var sidebar: some View {
        VStack(spacing: 0) {
            // App Icon 部分 - 重新设计
            VStack(spacing: 16) {
                // 应用图标容器
                ZStack {
                    // 背景渐变
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.1),
                                    Color.purple.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    // 应用图标
                    Image("Logo")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                // 应用信息
                VStack(spacing: 4) {
                    Text("CTCClick")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("v\(self.getAppVersion())")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.regularMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
            
            // 分隔线
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            // 导航列表
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(Tabs.allCases, id: \.self) { tab in
                        NavigationTabButton(
                            tab: tab,
                            isSelected: selectedTab == tab,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            }
                        )
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
            }
            
            Spacer()
        }
        .frame(width: 260)
        .background(
            // 侧边栏背景
            Rectangle()
                .fill(.regularMaterial)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.primary.opacity(0.02)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        )
        .overlay(
            // 右边框
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(width: 1),
            alignment: .trailing
        )
    }

    @ViewBuilder var detailView: some View {
        // 右侧内容区域
        ZStack {
            // 背景
            Rectangle()
                .fill(.regularMaterial)
            
            // 内容
            Group {
                switch self.selectedTab {
                case .general:
                    GeneralSettingsTabView()
                case .apps:
                    AppsSettingsTabView()
                case .actions:
                    ActionSettingsTabView()
                case .newFile:
                    NewFileSettingsTabView()
                case .cdirs:
                    CommonDirsSettingTabView()
                case .about:
                    AboutSettingsTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            detailView
        }
        .frame(minWidth: 800, minHeight: 500)
        .background(.regularMaterial)
    }

    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.1.0"
    }
}

// 导航标签按钮组件
struct NavigationTabButton: View {
    let tab: Tabs
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 图标容器
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            isSelected 
                            ? tab.color.opacity(0.15)
                            : Color.clear
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(
                            isSelected 
                            ? tab.color
                            : .secondary
                        )
                }
                
                // 标签文本
                Text(LocalizedStringKey(tab.rawValue))
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(
                        isSelected 
                        ? .primary
                        : .secondary
                    )
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected 
                        ? Color.blue.opacity(0.1)
                        : Color.clear
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected 
                                ? tab.color.opacity(0.2)
                                : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.0 : 0.98)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

extension View {
    func removeSidebarToggle() -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigation) {
                EmptyView()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
