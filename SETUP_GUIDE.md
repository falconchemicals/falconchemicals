# SETUP_GUIDE.md - Falcon Chemicals Website Setup

## ⚡ 5-Minute Setup Guide

### Prerequisites
Choose **ONE** option:
- **Option A:** Node.js 12+ installed
- **Option B:** Python 3.6+ installed

### Step-by-Step Instructions

#### For Node.js Users:
```bash
# 1. Clone or download the repository
cd falcon-chemicals

# 2. Run the generator
node generate_product_images.js

# 3. Open in browser
# Simply open index.html in your web browser
```

#### For Python Users:
```bash
# 1. Clone or download the repository
cd falcon-chemicals

# 2. Run the generator
python3 generate_product_images.py

# 3. Open in browser
# Simply open index.html in your web browser
```

### Verify Installation
After running the generator, you should see:
- ✅ Console message: "✅ Complete! Created 44 product images."
- ✅ New folder: `assets/product-images/`
- ✅ 44 SVG files inside that folder

### Testing Locally
To see the website with a proper web server:

```bash
# Using Node.js (npm)
npm install http-server -g
http-server . -c-1 -p 8000
# Then open: http://localhost:8000

# OR using Python 2
python -m SimpleHTTPServer 8000

# OR using Python 3
python3 -m http.server 8000
```

---

## 📋 Troubleshooting

### Problem: "Command not found" (Node.js)
```bash
# Check if Node.js is installed
node --version

# If not installed, download from:
# https://nodejs.org/
```

### Problem: "Command not found" (Python)
```bash
# Check if Python 3 is installed
python3 --version

# OR try:
python --version

# If not installed, download from:
# https://www.python.org/
```

### Problem: Permission denied
```bash
# On Mac/Linux, make script executable
chmod +x generate_product_images.js
chmod +x generate_product_images.py

# Then try running again
node generate_product_images.js
```

### Problem: Images still not showing
1. Close and reopen your browser
2. Press Ctrl+Shift+Delete to clear cache
3. Check that `assets/product-images/` exists
4. Verify 44 files are in that folder
5. Check browser console for errors (F12)

---

## 🎯 What Happens After Running the Generator?

1. **Directory Created:** `assets/product-images/`
2. **44 SVG Files Generated:** One for each chemical product
3. **Website Updated:** Products in index.html now display images
4. **Ready to Use:** Open index.html to view the complete website

---

## 📦 File Structure

```
falcon-chemicals/
├── index.html                          # Main website
├── generate_product_images.js          # Node.js generator
├── generate_product_images.py          # Python generator
├── package.json                        # npm configuration
├── .gitignore                          # Git configuration
├── SETUP_GUIDE.md                      # This file
├── IMPROVEMENTS.md                     # Detailed documentation
└── assets/
    └── product-images/                 # Generated images
        ├── acetic-anhydride.svg
        ├── ammonium-acetate.svg
        └── ... (44 total)
```

---

## 🚀 Production Deployment

### For GitHub Pages:
1. Make sure `assets/product-images/` is committed
2. Run generator locally before pushing
3. Push to main branch
4. GitHub Pages automatically serves index.html

### For Hosting Services:
1. Run generator locally
2. Upload entire folder to hosting
3. Make sure `assets/` folder is included
4. Access via your domain

---

## 💡 Tips & Tricks

**Want to update images?**
```bash
# Just run the generator again
node generate_product_images.js
```

**Want to modify colors?**
- Edit the `themeMap` object in the generator file
- Run generator again
- Colors update automatically

**Want to add new products?**
- Add entry to `products` array
- Run generator again
- New image automatically created

---

## ❓ Questions?

Check the detailed guide: [IMPROVEMENTS.md](./IMPROVEMENTS.md)

---

**Last Updated:** 2026-05-07
**Version:** 1.0.0
