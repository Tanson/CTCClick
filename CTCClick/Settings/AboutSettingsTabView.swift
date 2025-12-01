//
//  AboutSettingsTabView.swift
//  CTCClick
//
//  Created by 李旭 on 2024/4/4.
//

import AppKit
import ExtensionFoundation
import ExtensionKit
import FinderSync
import SwiftUI

struct AboutSettingsTabView: View {
    let messager = Messager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 页面标题
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("关于 CTCClick")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("了解应用程序信息和版本详情")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 4)
                
                // 应用信息卡片
                VStack(spacing: 24) {
                    // 应用图标和基本信息
                    VStack(spacing: 16) {
                        // 应用图标
                        ZStack {
                            // 背景渐变
                            RoundedRectangle(cornerRadius: 20)
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
                                .frame(width: 96, height: 96)
                            
                            // 应用图标
                            Image("Logo")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                        }
                        
                        // 应用名称和版本
                        VStack(spacing: 6) {
                            Text("CTCClick")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                // 版本号标签
                                HStack(spacing: 4) {
                                    Image(systemName: "tag.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.blue)
                                    
                                    Text("版本 \(getAppVersion())")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(.blue.opacity(0.1))
                                        .overlay(
                                            Capsule()
                                                .stroke(.blue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                
                                // 构建号标签
                                HStack(spacing: 4) {
                                    Image(systemName: "hammer.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.orange)
                                    
                                    Text("构建 \(getBuildVersion())")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(.orange.opacity(0.1))
                                        .overlay(
                                            Capsule()
                                                .stroke(.orange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    
                    // 应用描述
                    VStack(spacing: 12) {
                        Text("应用简介")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("CTCClick 是一个强大的右键菜单扩展工具，让您可以轻松添加应用程序来打开文件夹，并包含许多实用的常用操作功能。通过简洁直观的界面，您可以快速配置和管理右键菜单项，提升日常工作效率。")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 16)
                    }
                    
                    // 功能特性
                    VStack(spacing: 16) {
                        Text("主要功能")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            FeatureCard(
                                icon: "apps.ipad.landscape",
                                title: "应用管理",
                                description: "添加和管理右键菜单中的应用程序",
                                color: .purple
                            )
                            
                            FeatureCard(
                                icon: "bolt.square",
                                title: "快捷操作",
                                description: "提供常用的文件和文件夹操作",
                                color: .orange
                            )
                            
                            FeatureCard(
                                icon: "doc.badge.plus",
                                title: "新建文件",
                                description: "快速创建各种类型的新文件",
                                color: .green
                            )
                            
                            FeatureCard(
                                icon: "folder.badge.gearshape",
                                title: "文件夹管理",
                                description: "管理常用文件夹的访问权限",
                                color: .indigo
                            )
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                )
                
                // 版权信息
                VStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(height: 1)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "c.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("Copyright © 2025 tanson. All rights reserved")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }

    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.1.0"
    }

    func getBuildVersion() -> String {
        if let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return buildVersion
        }
        return "1"
    }
}

// 功能特性卡片组件
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

#Preview {
    AboutSettingsTabView()
}
