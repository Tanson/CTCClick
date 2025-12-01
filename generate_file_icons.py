#!/usr/bin/env python3
"""
生成文件类型图标的脚本
为CTCClick应用创建各种文件类型的图标
"""

import os
import json
from pathlib import Path

# 图标配置
ICON_CONFIGS = {
    # 办公文档
    'pdf': {'color': '#FF0000', 'text': 'PDF', 'bg_color': '#FFE6E6'},
    'rtf': {'color': '#0066CC', 'text': 'RTF', 'bg_color': '#E6F2FF'},
    'csv': {'color': '#00AA00', 'text': 'CSV', 'bg_color': '#E6FFE6'},
    
    # 开发文件
    'js': {'color': '#F7DF1E', 'text': 'JS', 'bg_color': '#FFFCE6'},
    'ts': {'color': '#3178C6', 'text': 'TS', 'bg_color': '#E6F2FF'},
    'py': {'color': '#3776AB', 'text': 'PY', 'bg_color': '#E6F2FF'},
    'java': {'color': '#ED8B00', 'text': 'JAVA', 'bg_color': '#FFF4E6'},
    'swift': {'color': '#FA7343', 'text': 'SWIFT', 'bg_color': '#FFF0E6'},
    'cpp': {'color': '#00599C', 'text': 'C++', 'bg_color': '#E6F2FF'},
    'c': {'color': '#A8B9CC', 'text': 'C', 'bg_color': '#F0F4F8'},
    'html': {'color': '#E34F26', 'text': 'HTML', 'bg_color': '#FFE6E6'},
    'css': {'color': '#1572B6', 'text': 'CSS', 'bg_color': '#E6F2FF'},
    'xml': {'color': '#FF6600', 'text': 'XML', 'bg_color': '#FFF0E6'},
    'yaml': {'color': '#CB171E', 'text': 'YAML', 'bg_color': '#FFE6E6'},
    'sql': {'color': '#336791', 'text': 'SQL', 'bg_color': '#E6F2FF'},
    'sh': {'color': '#4EAA25', 'text': 'SH', 'bg_color': '#E6FFE6'},
    'config': {'color': '#666666', 'text': 'CONF', 'bg_color': '#F0F0F0'},
    
    # 媒体文件
    'image': {'color': '#FF6B6B', 'text': 'IMG', 'bg_color': '#FFE6E6'},
    'video': {'color': '#4ECDC4', 'text': 'VID', 'bg_color': '#E6FFFF'},
    'audio': {'color': '#45B7D1', 'text': 'AUD', 'bg_color': '#E6F7FF'},
    'gif': {'color': '#FF9F43', 'text': 'GIF', 'bg_color': '#FFF4E6'},
    'svg': {'color': '#FFB142', 'text': 'SVG', 'bg_color': '#FFF8E6'},
}

def create_svg_icon(file_type, config):
    """创建SVG图标"""
    svg_content = f'''<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <!-- 文件背景 -->
  <rect x="8" y="4" width="40" height="52" rx="4" ry="4" fill="{config['bg_color']}" stroke="{config['color']}" stroke-width="2"/>
  
  <!-- 文件折角 -->
  <path d="M40 4 L48 12 L40 12 Z" fill="{config['color']}" opacity="0.3"/>
  <line x1="40" y1="4" x2="40" y2="12" stroke="{config['color']}" stroke-width="2"/>
  <line x1="40" y1="12" x2="48" y2="12" stroke="{config['color']}" stroke-width="2"/>
  
  <!-- 文件类型文本 -->
  <text x="28" y="42" text-anchor="middle" font-family="Arial, sans-serif" font-size="10" font-weight="bold" fill="{config['color']}">{config['text']}</text>
  
  <!-- 装饰线条 -->
  <line x1="14" y1="20" x2="34" y2="20" stroke="{config['color']}" stroke-width="1" opacity="0.5"/>
  <line x1="14" y1="24" x2="38" y2="24" stroke="{config['color']}" stroke-width="1" opacity="0.5"/>
  <line x1="14" y1="28" x2="32" y2="28" stroke="{config['color']}" stroke-width="1" opacity="0.5"/>
</svg>'''
    return svg_content

def create_imageset_contents(icon_name):
    """创建imageset的Contents.json文件"""
    return {
        "images": [
            {
                "filename": f"{icon_name}@1x.png",
                "idiom": "universal",
                "scale": "1x"
            },
            {
                "filename": f"{icon_name}@2x.png", 
                "idiom": "universal",
                "scale": "2x"
            },
            {
                "filename": f"{icon_name}@3x.png",
                "idiom": "universal", 
                "scale": "3x"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

def main():
    # 设置路径
    assets_path = Path("CTCClick/Assets.xcassets")
    
    if not assets_path.exists():
        print(f"错误: 找不到Assets.xcassets目录: {assets_path}")
        return
    
    print("开始生成文件类型图标...")
    
    for file_type, config in ICON_CONFIGS.items():
        icon_name = f"icon-file-{file_type}"
        imageset_dir = assets_path / f"{icon_name}.imageset"
        
        # 创建imageset目录
        imageset_dir.mkdir(exist_ok=True)
        
        # 创建SVG文件
        svg_content = create_svg_icon(file_type, config)
        svg_path = imageset_dir / f"{file_type}.svg"
        
        with open(svg_path, 'w', encoding='utf-8') as f:
            f.write(svg_content)
        
        # 创建Contents.json
        contents_json = create_imageset_contents(file_type)
        contents_path = imageset_dir / "Contents.json"
        
        with open(contents_path, 'w', encoding='utf-8') as f:
            json.dump(contents_json, f, indent=2)
        
        print(f"✓ 创建图标: {icon_name}")
    
    print(f"\n完成! 共生成了 {len(ICON_CONFIGS)} 个图标")
    print("注意: SVG文件已创建，但您可能需要使用工具将其转换为PNG格式的@1x、@2x、@3x版本")

if __name__ == "__main__":
    main()