# Image guidance

Ask for one image with these preferences:

- PNG, JPEG, HEIC, TIFF, or WebP; at most 50 MB.
- Ideal: 3840×2160 for landscape or 2400×2400 for square. Minimum: 2000 px on the long edge when possible.
- For a wide home hero, place the subject right of center and leave calmer space on the left for text.
- For a near-square Codex window, use a square or portrait-safe composition with the face away from extreme edges.
- Avoid important faces at the top or bottom 15%; `cover` cropping may remove them.
- A busy image is acceptable because Session mode uses a 60% content panel, but retain sufficient contrast around the home title.

If the image is low resolution, explain that it can still work but may soften on Retina displays. Do not silently replace the user's chosen image.

Do not estimate a centroid by default. The builder uses macOS Vision to detect all face rectangles, centers their union horizontally, and protects the highest head vertically. If detection returns zero faces, estimate a head-safe coordinate: prioritize the topmost head with a small margin above it, never the body center. Use manual focus only as a fallback or deliberate art-direction override.
