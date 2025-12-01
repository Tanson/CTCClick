#!/usr/bin/env python3
"""
Generate PNG icons from SVG for macOS app
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_icon(size, output_path):
    """Create a CTCClick icon with the specified size"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Scale factors
    scale = size / 512
    
    # Background gradient (simplified as solid color for PNG)
    bg_color = (79, 70, 229, 255)  # #4F46E5
    corner_radius = int(90 * scale)
    
    # Draw rounded rectangle background
    draw.rounded_rectangle([0, 0, size, size], radius=corner_radius, fill=bg_color)
    
    # Mouse dimensions
    mouse_x = int(160 * scale)
    mouse_y = int(140 * scale)
    mouse_w = int(120 * scale)
    mouse_h = int(150 * scale)
    
    # Mouse body
    mouse_color = (248, 250, 252, 255)  # #F8FAFC
    draw.rounded_rectangle([mouse_x, mouse_y, mouse_x + mouse_w, mouse_y + mouse_h], 
                          radius=int(20 * scale), fill=mouse_color)
    
    # Right button (highlighted)
    button_color = (254, 243, 199, 255)  # #FEF3C7
    button_x = mouse_x + int(60 * scale)
    button_y = mouse_y
    button_w = int(60 * scale)
    button_h = int(50 * scale)
    
    draw.rectangle([button_x, button_y, button_x + button_w, button_y + button_h], 
                  fill=button_color)
    
    # Scroll wheel
    wheel_color = (100, 116, 139, 255)  # #64748B
    wheel_x = mouse_x + int(55 * scale)
    wheel_y = mouse_y + int(25 * scale)
    wheel_w = int(10 * scale)
    wheel_h = int(20 * scale)
    
    draw.rounded_rectangle([wheel_x, wheel_y, wheel_x + wheel_w, wheel_y + wheel_h],
                          radius=int(5 * scale), fill=wheel_color)
    
    # Context menu
    menu_x = int(260 * scale)
    menu_y = int(175 * scale)
    menu_w = int(90 * scale)
    menu_h = int(120 * scale)
    
    # Menu background
    menu_bg = (255, 255, 255, 240)  # White with opacity
    draw.rounded_rectangle([menu_x, menu_y, menu_x + menu_w, menu_y + menu_h],
                          radius=int(8 * scale), fill=menu_bg)
    
    # Menu items (simplified as colored dots)
    dot_colors = [
        (59, 130, 246, 255),   # Blue
        (16, 185, 129, 255),   # Green  
        (245, 158, 11, 255),   # Yellow
        (239, 68, 68, 255),    # Red
        (139, 92, 246, 255),   # Purple
        (107, 114, 128, 255),  # Gray
    ]
    
    dot_size = max(2, int(6 * scale))
    for i, color in enumerate(dot_colors):
        dot_x = menu_x + int(12 * scale)
        dot_y = menu_y + int(12 * scale) + i * int(16 * scale)
        draw.ellipse([dot_x - dot_size//2, dot_y - dot_size//2, 
                     dot_x + dot_size//2, dot_y + dot_size//2], fill=color)
    
    # Click effect (simplified as lines)
    if size >= 64:  # Only draw for larger sizes
        effect_color = (245, 158, 11, 200)  # Orange with transparency
        line_width = max(1, int(2 * scale))
        
        start_x = int(280 * scale)
        start_y = int(210 * scale)
        
        # Three lines pointing to menu
        draw.line([start_x, start_y, start_x + int(15 * scale), start_y - int(10 * scale)], 
                 fill=effect_color, width=line_width)
        draw.line([start_x, start_y, start_x + int(15 * scale), start_y + int(10 * scale)], 
                 fill=effect_color, width=line_width)
        draw.line([start_x, start_y, start_x + int(20 * scale), start_y], 
                 fill=effect_color, width=line_width)
    
    # Save the image
    img.save(output_path, 'PNG')
    print(f"Generated {output_path} ({size}x{size})")

def main():
    # Icon sizes needed for macOS app
    icon_sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    # Output directory
    output_dir = "CTCClick/Assets.xcassets/AppIcon.appiconset"
    
    # Generate icons
    for size in icon_sizes:
        output_path = os.path.join(output_dir, f"icon_{size}.png")
        create_icon(size, output_path)
    
    print("\nAll icons generated successfully!")
    print("You can now replace the existing PNG files in AppIcon.appiconset with these new icons.")

if __name__ == "__main__":
    main()