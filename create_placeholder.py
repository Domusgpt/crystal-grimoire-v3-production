#!/usr/bin/env python3
"""Create placeholder image for unknown stones"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_unknown_stone_placeholder():
    # Create a 400x400 image with a subtle gradient background
    img = Image.new('RGB', (400, 400), color='#2c3e50')
    draw = ImageDraw.Draw(img)
    
    # Create gradient effect
    for y in range(400):
        shade = int(44 + (y / 400) * 30)  # Gradient from dark to slightly lighter
        color = f"#{shade:02x}{shade+10:02x}{shade+20:02x}"
        draw.line([(0, y), (400, y)], fill=color)
    
    # Draw a crystal/stone outline
    crystal_points = [
        (200, 50),   # top
        (120, 120),  # top left
        (100, 250),  # bottom left
        (200, 350),  # bottom
        (300, 250),  # bottom right
        (280, 120),  # top right
    ]
    
    # Draw crystal outline
    draw.polygon(crystal_points, outline='#ecf0f1', width=3, fill='#34495e')
    
    # Add inner lines for crystal facets
    draw.line([(200, 50), (200, 350)], fill='#ecf0f1', width=2)
    draw.line([(120, 120), (280, 120)], fill='#ecf0f1', width=2)
    draw.line([(100, 250), (300, 250)], fill='#ecf0f1', width=2)
    
    # Add question mark
    try:
        # Try to use a system font
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 60)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    # Draw question mark
    text = "?"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (400 - text_width) // 2
    y = (400 - text_height) // 2 - 20
    
    draw.text((x, y), text, fill='#ecf0f1', font=font)
    
    # Add "Unknown Stone" text
    try:
        text_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 24)
    except:
        text_font = ImageFont.load_default()
    
    text = "Unknown Stone"
    bbox = draw.textbbox((0, 0), text, font=text_font)
    text_width = bbox[2] - bbox[0]
    x = (400 - text_width) // 2
    y = 320
    
    draw.text((x, y), text, fill='#bdc3c7', font=text_font)
    
    # Save the image
    output_path = 'assets/placeholders/unknown-stone.jpg'
    img.save(output_path, 'JPEG', quality=85)
    print(f"Created placeholder image: {output_path}")
    
    return output_path

if __name__ == "__main__":
    create_unknown_stone_placeholder()