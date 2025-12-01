//
//  IconSelectorView.swift
//  CTCClick
//
//  Created by Assistant on 2024/10/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct IconSelectorView: View {
    @Binding var selectedIcon: String
    @State private var showingCustomIconPicker = false
    @State private var customIconURL: URL?
    
    // 内置图标库 - 扩充版本
    private let builtInIcons: [IconCategory] = [
        IconCategory(name: "办公文档", icons: [
            IconItem(name: "Word文档", iconName: "icon-file-docx", displayName: "DOCX"),
            IconItem(name: "Excel表格", iconName: "icon-file-xlsx", displayName: "XLSX"),
            IconItem(name: "PowerPoint", iconName: "icon-file-pptx", displayName: "PPTX"),
            IconItem(name: "PDF文档", iconName: "icon-file-pdf", displayName: "PDF"),
            IconItem(name: "文本文档", iconName: "icon-file-txt", displayName: "TXT"),
            IconItem(name: "RTF文档", iconName: "icon-file-rtf", displayName: "RTF"),
            IconItem(name: "CSV表格", iconName: "icon-file-csv", displayName: "CSV")
        ]),
        IconCategory(name: "开发文件", icons: [
            IconItem(name: "JSON数据", iconName: "icon-file-json", displayName: "JSON"),
            IconItem(name: "Markdown", iconName: "icon-file-md", displayName: "MD"),
            IconItem(name: "JavaScript", iconName: "icon-file-js", displayName: "JS"),
            IconItem(name: "TypeScript", iconName: "icon-file-ts", displayName: "TS"),
            IconItem(name: "Python", iconName: "icon-file-py", displayName: "PY"),
            IconItem(name: "Java", iconName: "icon-file-java", displayName: "JAVA"),
            IconItem(name: "Swift", iconName: "icon-file-swift", displayName: "SWIFT"),
            IconItem(name: "C++", iconName: "icon-file-cpp", displayName: "CPP"),
            IconItem(name: "C语言", iconName: "icon-file-c", displayName: "C"),
            IconItem(name: "HTML", iconName: "icon-file-html", displayName: "HTML"),
            IconItem(name: "CSS", iconName: "icon-file-css", displayName: "CSS"),
            IconItem(name: "XML", iconName: "icon-file-xml", displayName: "XML"),
            IconItem(name: "YAML", iconName: "icon-file-yaml", displayName: "YAML"),
            IconItem(name: "SQL", iconName: "icon-file-sql", displayName: "SQL"),
            IconItem(name: "Shell脚本", iconName: "icon-file-sh", displayName: "SH"),
            IconItem(name: "配置文件", iconName: "icon-file-config", displayName: "CONFIG")
        ]),
        IconCategory(name: "媒体文件", icons: [
            IconItem(name: "图片", iconName: "icon-file-image", displayName: "IMAGE"),
            IconItem(name: "视频", iconName: "icon-file-video", displayName: "VIDEO"),
            IconItem(name: "音频", iconName: "icon-file-audio", displayName: "AUDIO"),
            IconItem(name: "GIF动图", iconName: "icon-file-gif", displayName: "GIF"),
            IconItem(name: "SVG矢量", iconName: "icon-file-svg", displayName: "SVG")
        ]),
        IconCategory(name: "系统图标", icons: [
            IconItem(name: "文档", iconName: "document", displayName: "文档", isSystemIcon: true),
            IconItem(name: "文件夹", iconName: "folder", displayName: "文件夹", isSystemIcon: true),
            IconItem(name: "齿轮", iconName: "gearshape", displayName: "设置", isSystemIcon: true),
            IconItem(name: "星星", iconName: "star", displayName: "收藏", isSystemIcon: true),
            IconItem(name: "心形", iconName: "heart", displayName: "喜欢", isSystemIcon: true),
            IconItem(name: "标签", iconName: "tag", displayName: "标签", isSystemIcon: true)
        ])
    ]
    
    @State private var selectedCategory = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("选择图标")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // 分类选择器
            Picker("图标分类", selection: $selectedCategory) {
                ForEach(0..<builtInIcons.count, id: \.self) { index in
                    Text(builtInIcons[index].name)
                        .tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // 图标网格
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 12) {
                    ForEach(builtInIcons[selectedCategory].icons, id: \.iconName) { iconItem in
                        IconGridItem(
                            iconItem: iconItem,
                            isSelected: selectedIcon == iconItem.iconName,
                            onTap: {
                                selectedIcon = iconItem.iconName
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 200)
            
            Divider()
            
            // 自定义图标选项
            VStack(spacing: 12) {
                HStack {
                    Text("自定义图标")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    if let customURL = customIconURL {
                        HStack(spacing: 8) {
                            AsyncImage(url: customURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Rectangle()
                                    .fill(.secondary.opacity(0.3))
                            }
                            .frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            
                            Text(customURL.lastPathComponent)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            
                            Button(action: {
                                customIconURL = nil
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
                        showingCustomIconPicker = true
                    }) {
                        Text(customIconURL == nil ? "选择ICO文件" : "更换图标")
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
            .padding(.horizontal, 4)
        }
        .fileImporter(
            isPresented: $showingCustomIconPicker,
            allowedContentTypes: [.ico, .png, .jpeg],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                if let url = files.first {
                    // 获取安全访问权限
                    _ = url.startAccessingSecurityScopedResource()
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    // 复制文件到应用支持目录
                    let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                    let customIconsDir = appSupportURL.appendingPathComponent("CTCClick/CustomIcons")
                    
                    do {
                        try FileManager.default.createDirectory(at: customIconsDir, withIntermediateDirectories: true)
                        let destinationURL = customIconsDir.appendingPathComponent(url.lastPathComponent)
                        
                        // 如果文件已存在，先删除
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            try FileManager.default.removeItem(at: destinationURL)
                        }
                        
                        try FileManager.default.copyItem(at: url, to: destinationURL)
                        customIconURL = destinationURL
                        selectedIcon = "custom:\(destinationURL.path)"
                    } catch {
                        print("复制自定义图标失败: \(error)")
                    }
                }
            case .failure:
                break
            }
        }
    }
}

// 图标分类数据模型
struct IconCategory {
    let name: String
    let icons: [IconItem]
}

// 图标项数据模型
struct IconItem {
    let name: String
    let iconName: String
    let displayName: String
    let isSystemIcon: Bool
    
    init(name: String, iconName: String, displayName: String, isSystemIcon: Bool = false) {
        self.name = name
        self.iconName = iconName
        self.displayName = displayName
        self.isSystemIcon = isSystemIcon
    }
}

// 图标网格项组件
struct IconGridItem: View {
    let iconItem: IconItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .blue.opacity(0.2) : .secondary.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                if iconItem.isSystemIcon {
                    Image(systemName: iconItem.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .blue : .primary)
                } else {
                    Image(iconItem.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                }
            }
            
            Text(iconItem.displayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isSelected ? .blue : .secondary)
                .lineLimit(1)
        }
        .onTapGesture {
            onTap()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? .blue : .clear, lineWidth: 2)
        )
    }
}

// 扩展UTType以支持ICO文件
extension UTType {
    static let ico = UTType(filenameExtension: "ico") ?? UTType.data
}

#Preview {
    IconSelectorView(selectedIcon: .constant("icon-file-json"))
        .frame(width: 400, height: 400)
}