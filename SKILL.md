---
name: create-kpop-codex-theme
description: Create, install, switch, and refine complete K-pop-inspired themes for the official Codex desktop app on macOS from one user-supplied photo. Use when a user asks for a Codex skin, idol or group theme, K-pop wallpaper theme, custom home hero, readable Session background, artist-specific colors or copy, or a reusable desktop theme shortcut. Supports macOS only and requires the official com.openai.codex app.
---

# Create a K-pop Codex Theme

Turn one supplied image into a named macOS Codex theme with artist-aware copy, colors, home presentation, Session reading treatment, and an optional Desktop shortcut. Keep the official app and signature untouched; apply through loopback-only CDP.

## Workflow

1. Confirm macOS and locate the official Codex app (`com.openai.codex`). Do not claim support for the consumer ChatGPT app when its bundle identifier differs.
2. Ask the user to attach one image when none is available. Follow [image-guidance.md](references/image-guidance.md). This is the only required question.
3. Inspect the image. Infer an artist only when visual or conversational evidence is strong. Otherwise ask only for the artist or group name; never run face recognition or build a biometric identity database.
4. Ask no other design questions. Infer palette, era, motifs, copy, focus, and layout from the image and artist context. The entire workflow must require at most the image request plus one artist-name question.
5. Read [creative-direction.md](references/creative-direction.md). Produce an original concept using the image palette, composition, era, fashion, fan culture, and supplied context.
6. Read [theme-schema.md](references/theme-schema.md). Write a valid config JSON. Omit manual hero focus coordinates by default: the builder uses macOS Vision to detect every face, centers the group horizontally, and protects the highest head vertically. Keep Session content-panel opacity at `0.60` by default so text stays readable while the background remains atmospheric.
7. Prepare the image with macOS `sips`; do not distort aspect ratio. Prefer source width at least 2000 px and size at most 50 MB.
8. Build and validate the pack:

   ```bash
   NODE="/Applications/ChatGPT.app/Contents/Resources/cua_node/bin/node"
   "$NODE" scripts/build-theme.mjs --config /path/config.json --image /path/prepared.jpg --output /path/theme-pack
   "$NODE" scripts/injector.mjs --check-payload --theme-dir /path/theme-pack
   ```

9. Before writing outside the workspace, restarting Codex, or opening CDP, request the required permission. Install with:

   ```bash
   scripts/install-theme-macos.sh --image /path/image --config /path/config.json --id theme-id --shortcut --apply
   ```

10. Inspect the builder result. Report `faceCount`, `focusStrategy`, and the chosen hero coordinates. If no face was detected, visually estimate a head-safe focus or use `faceFocusMode: "manual"`; do not use a body centroid.
11. Verify the live renderer. Report whether the home route, sidebar, composer, and overflow checks pass. If the user is on a Session route, do not claim the home hero was visually verified.
12. Iterate one variable at a time when tuning opacity or focus. State the before and after values.

## Creative rules

- Generate a coherent system, not merely a renamed wallpaper: title, subtitle, tagline, status, quote, project label, emoji/motif, palette, and image focus must tell the same story.
- Use English for all generated UI copy by default. Use another language only when the user explicitly requests it.
- Preserve native Codex controls and user data. Do not fake the whole UI with a screenshot.
- Prefer artist or fandom slogans, album/era references, and original microcopy.
- Add one or two recognizable, very short lyric fragments when confidently associated with the artist; keep all automatically sourced lyric text within 10 words total. Never reproduce verses. Use exact longer text only when the user supplies it.
- Do not imply artist endorsement. Warn before public or commercial redistribution of celebrity images, trademarks, logos, or lyrics.
- Keep CDP bound to `127.0.0.1`; never modify `.app`, `app.asar`, signatures, API keys, model providers, or Base URLs.

## Output

Deliver a theme pack containing `theme.json` and one prepared background image. When requested, install it under `~/Library/Application Support/CodexKpopTheme/themes/<id>` and create a marked Desktop `.command` launcher. Preserve previous packs so switching is reversible.
