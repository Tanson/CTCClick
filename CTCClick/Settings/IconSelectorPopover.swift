//
//  IconSelectorPopover.swift
//  CTCClick
//
//  Created by Assistant on 2024/11/18.
//

import SwiftUI
import UniformTypeIdentifiers

struct IconSelectorPopover: View {
    @Binding var selectedIcon: String
    @Binding var isPresented: Bool
    @State private var showingFilePicker = false
    
    // 图标分类
    private let iconCategories: [IconCategory] = [
        IconCategory(
            name: "办公文档",
            icons: [
                IconItem(name: "icon-file-pdf", iconName: "icon-file-pdf", displayName: "PDF"),
                IconItem(name: "icon-file-docx", iconName: "icon-file-docx", displayName: "Word"),
                IconItem(name: "icon-file-xlsx", iconName: "icon-file-xlsx", displayName: "Excel"),
                IconItem(name: "icon-file-pptx", iconName: "icon-file-pptx", displayName: "PowerPoint"),
                IconItem(name: "icon-file-txt", iconName: "icon-file-txt", displayName: "文本"),
                IconItem(name: "icon-file-rtf", iconName: "icon-file-rtf", displayName: "RTF"),
                IconItem(name: "icon-file-csv", iconName: "icon-file-csv", displayName: "CSV")
            ]
        ),
        IconCategory(
            name: "开发文件",
            icons: [
                IconItem(name: "icon-file-js", iconName: "icon-file-js", displayName: "JavaScript"),
                IconItem(name: "icon-file-ts", iconName: "icon-file-ts", displayName: "TypeScript"),
                IconItem(name: "icon-file-py", iconName: "icon-file-py", displayName: "Python"),
                IconItem(name: "icon-file-java", iconName: "icon-file-java", displayName: "Java"),
                IconItem(name: "icon-file-swift", iconName: "icon-file-swift", displayName: "Swift"),
                IconItem(name: "icon-file-cpp", iconName: "icon-file-cpp", displayName: "C++"),
                IconItem(name: "icon-file-c", iconName: "icon-file-c", displayName: "C"),
                IconItem(name: "icon-file-html", iconName: "icon-file-html", displayName: "HTML"),
                IconItem(name: "icon-file-css", iconName: "icon-file-css", displayName: "CSS"),
                IconItem(name: "icon-file-xml", iconName: "icon-file-xml", displayName: "XML"),
                IconItem(name: "icon-file-json", iconName: "icon-file-json", displayName: "JSON"),
                IconItem(name: "icon-file-yaml", iconName: "icon-file-yaml", displayName: "YAML"),
                IconItem(name: "icon-file-sql", iconName: "icon-file-sql", displayName: "SQL"),
                IconItem(name: "icon-file-sh", iconName: "icon-file-sh", displayName: "Shell"),
                IconItem(name: "icon-file-config", iconName: "icon-file-config", displayName: "配置"),
                IconItem(name: "icon-file-md", iconName: "icon-file-md", displayName: "Markdown")
            ]
        ),
        IconCategory(
            name: "媒体文件",
            icons: [
                IconItem(name: "icon-file-image", iconName: "icon-file-image", displayName: "图片"),
                IconItem(name: "icon-file-video", iconName: "icon-file-video", displayName: "视频"),
                IconItem(name: "icon-file-audio", iconName: "icon-file-audio", displayName: "音频"),
                IconItem(name: "icon-file-gif", iconName: "icon-file-gif", displayName: "GIF"),
                IconItem(name: "icon-file-svg", iconName: "icon-file-svg", displayName: "SVG")
            ]
        ),
        IconCategory(
            name: "系统图标",
            icons: [
                IconItem(name: "document", iconName: "document", displayName: "文档"),
                IconItem(name: "folder", iconName: "folder", displayName: "文件夹"),
                IconItem(name: "doc.text", iconName: "doc.text", displayName: "文本"),
                IconItem(name: "doc.richtext", iconName: "doc.richtext", displayName: "富文本"),
                IconItem(name: "doc.plaintext", iconName: "doc.plaintext", displayName: "纯文本"),
                IconItem(name: "terminal", iconName: "terminal", displayName: "终端")
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("选择图标")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("完成") {
                    isPresented = false
                }
                .foregroundColor(.blue)
                .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            // 内容区域
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(iconCategories, id: \.name) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(70), spacing: 8), count: 6), spacing: 12) {
                                ForEach(category.icons, id: \.name) { icon in
                                    IconGridItemModern(
                                        icon: icon,
                                        isSelected: selectedIcon == icon.name,
                                        onTap: {
                                            selectedIcon = icon.name
                                            isPresented = false
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // 自定义图标部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text("自定义图标")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            showingFilePicker = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                
                                Text("选择自定义图标")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.blue.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .frame(minWidth: 500, minHeight: 600)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.png, .jpeg],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                if let url = files.first {
                    handleCustomIconSelection(url: url)
                }
            case .failure(let error):
                print("Error selecting custom icon: \(error)")
            }
        }
    }
    
    private func handleCustomIconSelection(url: URL) {
        // 获取应用支持目录
        guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        
        let customIconsDir = appSupportDir.appendingPathComponent("CTCClick/CustomIcons")
        
        // 创建目录（如果不存在）
        try? FileManager.default.createDirectory(at: customIconsDir, withIntermediateDirectories: true)
        
        // 生成唯一文件名
        let fileName = "\(UUID().uuidString).\(url.pathExtension)"
        let destinationURL = customIconsDir.appendingPathComponent(fileName)
        
        do {
            // 复制文件
            try FileManager.default.copyItem(at: url, to: destinationURL)
            selectedIcon = "custom:\(destinationURL.path)"
            isPresented = false
        } catch {
            print("Error copying custom icon: \(error)")
        }
    }
}

struct IconGridItemModern: View {
    let icon: IconItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? .blue.opacity(0.15) : Color(.controlBackgroundColor))
                        .frame(width: 60, height: 60)
                    
                    if icon.name.starts(with: "icon-") {
                        Image(icon.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    } else {
                        Image(systemName: icon.iconName)
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? .blue : .clear, lineWidth: 2)
                )
                
                Text(icon.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 60)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 70, height: 85)
    }
}

// 扩展 UTType 以支持 ICO 格式
// 移除重复的UTType扩展，使用IconSelectorView.swift中的定义