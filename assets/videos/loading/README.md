# Loading Videos

This directory contains mystical crystal loading animations for the Crystal Grimoire app.

## Video Assets (Not in Git)
The actual video files are stored separately due to size constraints:
- 20250530_0201_Chakras in Color_loop.mp4
- 20250530_0220_Crystal Metamorphosis Magic.mp4
- 20250530_0223_Crystal Cave Wonder.mp4
- 20250530_0225_Gemstone Universe.mp4
- 20250530_0229_Gemstone Mandala Magic.mp4
- And 35+ more mystical crystal animations

## For Deployment
Videos should be:
1. Optimized for web (compressed)
2. Hosted on CDN (Firebase Storage/CloudFlare)
3. Lazy loaded in VideoLoadingScreen widget

## Usage
The VideoLoadingScreen widget randomly selects from available videos to display during:
- Crystal identification processing
- AI analysis loading
- Feature transitions