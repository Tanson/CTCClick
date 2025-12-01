#!/usr/bin/env python3
import os
import json
import glob

# 获取所有icon-file-*的imageset目录
base_path = "/Users/tanson/Desktop/开发/访达右键菜单/CTCClick/Assets.xcassets"
icon_dirs = glob.glob(os.path.join(base_path, "icon-file-*.imageset"))

for icon_dir in icon_dirs:
    contents_json_path = os.path.join(icon_dir, "Contents.json")
    
    # 检查目录中的文件
    files_in_dir = os.listdir(icon_dir)
    svg_files = [f for f in files_in_dir if f.endswith('.svg')]
    png_files = [f for f in files_in_dir if f.endswith('.png')]
    
    if svg_files:
        # 如果有SVG文件，使用SVG
        filename = svg_files[0]
        new_config = {
            "images": [
                {
                    "filename": filename,
                    "idiom": "universal"
                }
            ],
            "info": {
                "author": "xcode",
                "version": 1
            }
        }
    elif png_files:
        # 如果只有PNG文件，使用PNG配置
        png_1x = [f for f in png_files if '@1x' in f or (not '@' in f and f.endswith('.png'))]
        png_2x = [f for f in png_files if '@2x' in f]
        png_3x = [f for f in png_files if '@3x' in f]
        
        images = []
        if png_1x:
            images.append({"filename": png_1x[0], "idiom": "universal", "scale": "1x"})
        if png_2x:
            images.append({"filename": png_2x[0], "idiom": "universal", "scale": "2x"})
        if png_3x:
            images.append({"filename": png_3x[0], "idiom": "universal", "scale": "3x"})
        
        new_config = {
            "images": images,
            "info": {
                "author": "xcode",
                "version": 1
            }
        }
    else:
        print(f"No image files found in {icon_dir}")
        continue
    
    # 写入新的配置
    with open(contents_json_path, 'w') as f:
        json.dump(new_config, f, indent=2)
    
    print(f"Fixed {os.path.basename(icon_dir)}")

print("All icon configurations fixed!")
