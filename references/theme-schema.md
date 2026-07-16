# Theme config schema

Pass a JSON object to `scripts/build-theme.mjs`.

```json
{
  "id": "jennie-ruby",
  "name": "JENNIE × CODEX",
  "brandSubtitle": "RUBY EDITION",
  "tagline": "Turn bright ideas into code.",
  "projectPrefix": "✦  ",
  "projectLabel": "🖤  JENNIE PROJECTS",
  "statusText": "RUBY MODE ON",
  "quote": "CREATE IT YOUR WAY",
  "layout": {
    "sessionPanelOpacity": 0.6
  },
  "colors": {
    "background": "#080b14",
    "panel": "#111827",
    "panelAlt": "#171f32",
    "accent": "#f2a6c6",
    "accentAlt": "#ff79b0",
    "secondary": "#8edcff",
    "highlight": "#b51f5a",
    "text": "#fffafc",
    "muted": "#c7b8c2"
  }
}
```

All colors must be six-digit hex values. Limits: name/subtitle/status/quote/project label 80 characters; tagline 160; project prefix 40. The builder creates the image filename and `line` color.

By default the builder uses macOS Vision to detect every face. It centers the union of the group horizontally and chooses a head-safe vertical position that protects the highest face from an ultra-wide `cover` crop. The generated theme records `faceCount`, `focusStrategy`, `heroFocusX`, and `heroFocusY`.

For an intentional override, set `layout.faceFocusMode` to `"manual"` and supply `heroFocusX` and `heroFocusY` as 0–100 percentages. Without manual mode, detected coordinates take priority and older stored coordinates serve only as a fallback when no face is found. `sessionPanelOpacity` accepts 0.2–0.9 and defaults to 0.6.

The bundled CSS defaults to a 60% Session content panel. Tune the CSS only after the user compares a live result; change one visibility variable at a time and preserve the home presentation.
