//
//  CommonDirsSettingTabView.swift
//  CTCClick
//
//  Created by 李旭 on 2024/11/18.
//

import SwiftUI

struct CommonDirsSettingTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingImporter = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题和按钮
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("常用目录管理")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("管理右键菜单中的常用目录快捷访问")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingImporter = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 12, weight: .medium))
                        
                        Text("添加目录")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .green.opacity(0.3), radius: 3, x: 0, y: 1)
                    )
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            // 目录列表
            if appState.cdirs.isEmpty {
                // 空状态
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.green.opacity(0.1), .blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 26))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    
                    VStack(spacing: 6) {
                        Text("暂无常用目录")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("点击上方的\"添加目录\"按钮来添加常用目录")
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
                        ForEach(appState.cdirs, id: \.self) { dir in
                            DirectoryCardView(
                                directory: dir,
                                onRevealInFinder: {
                                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: dir.url.path)
                                },
                                onDelete: {
                                    appState.removeCommonDir(dir)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    appState.saveCommonDir(url)
                }
            case .failure(let error):
                print("Error importing directory: \(error)")
            }
        }
    }
}

// 目录卡片视图
struct DirectoryCardView: View {
    let directory: CommonDir
    let onRevealInFinder: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // 文件夹图标
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.1), .green.opacity(0.1)], 
                        startPoint: .topLeading, 
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "folder.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
            
            // 目录信息
            VStack(alignment: .leading, spacing: 3) {
                Text(directory.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(directory.url.path)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            // 操作按钮
            HStack(spacing: 8) {
                Button(action: onRevealInFinder) {
                    Image(systemName: "eye")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(.blue.opacity(0.1))
                        )
                }
                .buttonStyle(.borderless)
                .help("在访达中显示")
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(.red.opacity(0.1))
                        )
                }
                .buttonStyle(.borderless)
                .help("删除目录")
            }
            .opacity(isHovered ? 1.0 : 0.7)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(isHovered ? 0.2 : 0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    CommonDirsSettingTabView()
        .environmentObject(AppState())
}
