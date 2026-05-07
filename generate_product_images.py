#!/usr/bin/env python3

"""
Falcon Chemicals - Product Image Generator (Python)
Generates professional SVG product packaging images for all 44 chemical compounds
Usage: python3 generate_product_images.py
"""

import os
import sys
from pathlib import Path

# Create assets directory
assets_dir = Path(__file__).parent / 'assets' / 'product-images'
assets_dir.mkdir(parents=True, exist_ok=True)
print(f'✓ Directory ready: {assets_dir}')

# Product data matching the HTML file
products = [
    {"name": "Acetic anhydride", "category": "Other", "packaging": "bag"},
    {"name": "Ammonium acetate", "category": "Ammonium", "packaging": "jerrycan"},
    {"name": "Ammonium ferrous sulfate", "category": "Ammonium", "packaging": "jerrycan"},
    {"name": "Ammonium formate", "category": "Ammonium", "packaging": "jerrycan"},
    {"name": "Ammonium nitrate", "category": "Ammonium", "packaging": "bag"},
    {"name": "Ammonium oxalate", "category": "Ammonium", "packaging": "jerrycan"},
    {"name": "Ammonium phosphate", "category": "Ammonium", "packaging": "bag"},
    {"name": "Ammonium salicylate", "category": "Ammonium", "packaging": "jerrycan"},
    {"name": "Ammonium sulfate", "category": "Ammonium", "packaging": "drum"},
    {"name": "Ammonium tartrate", "category": "Ammonium", "packaging": "jerrycan"},
    {"name": "Calcium lactate", "category": "Calcium", "packaging": "jerrycan"},
    {"name": "Calcium nitrate", "category": "Calcium", "packaging": "bag"},
    {"name": "Calcium oxalate", "category": "Calcium", "packaging": "jerrycan"},
    {"name": "Calcium phosphate", "category": "Calcium", "packaging": "bag"},
    {"name": "Hydrochloric acid 37%", "category": "Acid", "packaging": "drum"},
    {"name": "Lead acetate", "category": "Lead", "packaging": "jerrycan"},
    {"name": "Lead nitrate", "category": "Lead", "packaging": "jerrycan"},
    {"name": "Lead sulfate", "category": "Lead", "packaging": "jerrycan"},
    {"name": "Nitric acid 60%", "category": "Acid", "packaging": "drum"},
    {"name": "Picric acid", "category": "Acid", "packaging": "drum"},
    {"name": "Potassium acetate", "category": "Potassium", "packaging": "jerrycan"},
    {"name": "Potassium fluoride", "category": "Potassium", "packaging": "jerrycan"},
    {"name": "Potassium nitrate", "category": "Potassium", "packaging": "bag"},
    {"name": "Potassium oxalate", "category": "Potassium", "packaging": "jerrycan"},
    {"name": "Potassium phosphate di", "category": "Potassium", "packaging": "bag"},
    {"name": "Potassium phosphate mono", "category": "Potassium", "packaging": "bag"},
    {"name": "Potassium phosphate tri", "category": "Potassium", "packaging": "drum"},
    {"name": "Potassium sulfate", "category": "Potassium", "packaging": "bag"},
    {"name": "Potassium tartrate", "category": "Potassium", "packaging": "jerrycan"},
    {"name": "Silver nitrate", "category": "Other", "packaging": "jerrycan"},
    {"name": "Sodium acetate", "category": "Sodium", "packaging": "jerrycan"},
    {"name": "Sodium fluoride", "category": "Sodium", "packaging": "jerrycan"},
    {"name": "Sodium nitrate", "category": "Sodium", "packaging": "bag"},
    {"name": "Sodium oxalate", "category": "Sodium", "packaging": "jerrycan"},
    {"name": "Sodium phosphate di", "category": "Sodium", "packaging": "bag"},
    {"name": "Sodium phosphate mono", "category": "Sodium", "packaging": "jerrycan"},
    {"name": "Sodium phosphate tri", "category": "Sodium", "packaging": "drum"},
    {"name": "Sodium potassium tartrate", "category": "Sodium", "packaging": "jerrycan"},
    {"name": "Sodium sulfate", "category": "Sodium", "packaging": "bag"},
    {"name": "Sodium tartrate", "category": "Sodium", "packaging": "jerrycan"},
    {"name": "Zinc acetate", "category": "Zinc", "packaging": "jerrycan"},
    {"name": "Zinc nitrate", "category": "Zinc", "packaging": "bag"},
    {"name": "Zinc phosphate", "category": "Zinc", "packaging": "bag"},
    {"name": "Zinc sulfate", "category": "Zinc", "packaging": "bag"}
]

# Color theme for each category
theme_map = {
    "Ammonium": {"main": "#164e63", "soft": "#e0f2fe", "accent": "#c81e1e", "label": "NH4"},
    "Calcium": {"main": "#047857", "soft": "#dcfce7", "accent": "#84cc16", "label": "Ca"},
    "Acid": {"main": "#b91c1c", "soft": "#fee2e2", "accent": "#f97316", "label": "H+"},
    "Lead": {"main": "#475569", "soft": "#e2e8f0", "accent": "#94a3b8", "label": "Pb"},
    "Potassium": {"main": "#7c3aed", "soft": "#ede9fe", "accent": "#c81e1e", "label": "K"},
    "Sodium": {"main": "#2563eb", "soft": "#dbeafe", "accent": "#38bdf8", "label": "Na"},
    "Zinc": {"main": "#b45309", "soft": "#fef3c7", "accent": "#c81e1e", "label": "Zn"},
    "Other": {"main": "#101828", "soft": "#f1f5f9", "accent": "#c81e1e", "label": "Rx"}
}

def get_initials(name):
    """Get product initials from name"""
    name = name.replace("%", "").replace("0", "").replace("1", "").replace("2", "").replace("3", "").replace("4", "").replace("5", "").replace("6", "").replace("7", "").replace("8", "").replace("9", "")
    words = [w for w in name.split() if w][:2]
    return "".join([w[0].upper() for w in words])

def generate_product_svg(product, index):
    """Generate SVG for a product"""
    theme = theme_map.get(product["category"], theme_map["Other"])
    code = get_initials(product["name"])
    fill_level = 74 + (index % 4) * 8
    
    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg viewBox="0 0 320 190" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="{product['name']} product image">
  <defs>
    <linearGradient id="grad{index}" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:{theme['soft']};stop-opacity:1" />
      <stop offset="100%" style="stop-color:#ffffff;stop-opacity:1" />
    </linearGradient>
    <filter id="shadow{index}" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="3" stdDeviation="4" flood-color="#000000" flood-opacity="0.12"/>
    </filter>
  </defs>
  
  <!-- Background -->
  <rect width="320" height="190" fill="url(#grad{index})"/>
  
  <!-- Decorative circles -->
  <circle cx="272" cy="30" r="66" fill="{theme['main']}" opacity="0.08"/>
  <circle cx="36" cy="164" r="54" fill="{theme['accent']}" opacity="0.08"/>
  
  <!-- Base shadow ellipse -->
  <ellipse cx="160" cy="166" rx="82" ry="13" fill="#0f172a" opacity="0.08"/>
  
  <!-- Main container (bottle/bucket) -->
  <g filter="url(#shadow{index})">
    <!-- Container body -->
    <rect x="104" y="30" width="112" height="136" rx="14" fill="#ffffff" stroke="{theme['main']}" stroke-width="5"/>
    
    <!-- Container cap -->
    <rect x="122" y="14" width="76" height="32" rx="8" fill="#cbd5e1" stroke="{theme['main']}" stroke-width="4"/>
    
    <!-- Liquid fill -->
    <path d="M104 {fill_level}h112v76a14 14 0 0 1-14 14h-84a14 14 0 0 1-14-14Z" fill="{theme['main']}" opacity="0.88"/>
    
    <!-- Label area -->
    <rect x="122" y="78" width="76" height="48" rx="8" fill="#ffffff" opacity="0.94"/>
    
    <!-- Category label -->
    <text x="160" y="104" text-anchor="middle" fill="{theme['main']}" font-size="24" font-weight="900" font-family="Inter, Arial, sans-serif">{theme['label']}</text>
    
    <!-- Product code -->
    <text x="160" y="149" text-anchor="middle" fill="#ffffff" font-size="22" font-weight="900" font-family="Inter, Arial, sans-serif">{code}</text>
    
    <!-- Accent decoration -->
    <path d="M236 70c18 0 34 13 34 31s-16 31-34 31" fill="none" stroke="{theme['accent']}" stroke-width="8" stroke-linecap="round" opacity="0.72"/>
  </g>
  
  <!-- Falcon branding footer -->
  <text x="160" y="180" text-anchor="middle" fill="#64748b" font-size="8" font-weight="700" font-family="Inter, Arial, sans-serif">Falcon Chemicals</text>
</svg>'''
    return svg

def get_filename(name):
    """Generate filename from product name"""
    filename = name.lower()
    filename = filename.replace("%", "percent")
    filename = filename.replace(" ", "-")
    for char in "!@#$%^&*()=+[]{}\\|;:'\",<>?/":
        filename = filename.replace(char, "")
    return filename + ".svg"

def generate_all_images():
    """Generate all product images"""
    created = 0
    skipped = 0
    
    print('\n🎨 Generating Falcon Chemicals product images...\n')
    
    for index, product in enumerate(products):
        filename = get_filename(product["name"])
        filepath = assets_dir / filename
        svg = generate_product_svg(product, index)
        
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(svg)
            created += 1
            print(f'✓ {filename}')
        except Exception as e:
            skipped += 1
            print(f'✗ Failed to create {filename}: {str(e)}')
    
    print('\n' + '=' * 60)
    print(f'✅ Complete! Created {created} product images.')
    print(f'📁 Location: {assets_dir}')
    print('=' * 60 + '\n')
    
    if skipped > 0:
        print(f'⚠️  {skipped} image(s) could not be created.')

if __name__ == '__main__':
    generate_all_images()
