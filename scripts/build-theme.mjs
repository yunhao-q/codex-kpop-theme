import fs from "node:fs/promises";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const args = process.argv.slice(2);
const value = (name) => {
  const index = args.indexOf(`--${name}`);
  if (index < 0 || !args[index + 1]) throw new Error(`Missing --${name}`);
  return args[index + 1];
};
const hex = (input, name) => {
  if (!/^#[0-9a-f]{6}$/i.test(input)) throw new Error(`${name} must be #RRGGBB`);
  return input.toLowerCase();
};
const text = (input, fallback, limit) => String(input || fallback).trim().slice(0, limit) || fallback;
const number = (input, fallback, min, max) => {
  const parsed = Number(input);
  return Number.isFinite(parsed) ? Math.min(max, Math.max(min, parsed)) : fallback;
};
const detectFaceFocus = (image) => {
  const script = path.join(path.dirname(fileURLToPath(import.meta.url)), "detect-face-focus.swift");
  const result = spawnSync("/usr/bin/swift", [script, image], {
    encoding: "utf8",
    timeout: 30000,
    maxBuffer: 1024 * 1024,
    env: {
      ...process.env,
      SWIFT_MODULECACHE_PATH: "/tmp/codex-kpop-theme-swift-cache",
      CLANG_MODULE_CACHE_PATH: "/tmp/codex-kpop-theme-clang-cache",
    },
  });
  if (result.status !== 0) return null;
  try {
    const detected = JSON.parse(result.stdout);
    return detected.faceCount > 0 ? detected : null;
  } catch {
    return null;
  }
};

const configPath = path.resolve(value("config"));
const imagePath = path.resolve(value("image"));
const outputDir = path.resolve(value("output"));
const raw = JSON.parse(await fs.readFile(configPath, "utf8"));
const stat = await fs.stat(imagePath);
if (!stat.isFile() || stat.size < 1 || stat.size > 16 * 1024 * 1024) {
  throw new Error("Prepared image must be non-empty and no larger than 16 MB");
}
const manualFaceFocus = raw.layout?.faceFocusMode === "manual";
const detectedFocus = manualFaceFocus ? null : detectFaceFocus(imagePath);

await fs.mkdir(outputDir, { recursive: true, mode: 0o700 });
const extension = path.extname(imagePath).toLowerCase();
if (![".png", ".jpg", ".jpeg", ".webp"].includes(extension)) throw new Error("Unsupported image format");
const imageName = `background${extension === ".jpeg" ? ".jpg" : extension}`;
await fs.copyFile(imagePath, path.join(outputDir, imageName));
await fs.chmod(path.join(outputDir, imageName), 0o600);

const accent = hex(raw.colors?.accent || "#ff5fa2", "accent");
const secondary = hex(raw.colors?.secondary || "#8edcff", "secondary");
const highlight = hex(raw.colors?.highlight || "#8b5cf6", "highlight");
const theme = {
  schemaVersion: 1,
  id: text(raw.id, `kpop-${Date.now()}`, 80),
  name: text(raw.name, "K-pop × Codex", 80),
  brandSubtitle: text(raw.brandSubtitle, "K-POP EDITION", 80),
  tagline: text(raw.tagline, "Turn inspiration into code.", 160),
  projectPrefix: text(raw.projectPrefix, "✦  ", 40),
  projectLabel: text(raw.projectLabel, "💿  K-POP PROJECTS", 80),
  statusText: text(raw.statusText, "CREATIVE MODE ON", 80),
  quote: text(raw.quote, "CREATE YOUR OWN ERA", 80),
  image: imageName,
  layout: {
    heroFocusX: manualFaceFocus
      ? number(raw.layout?.heroFocusX, 62, 0, 100)
      : number(detectedFocus?.heroFocusX, raw.layout?.heroFocusX ?? 62, 0, 100),
    heroFocusY: manualFaceFocus
      ? number(raw.layout?.heroFocusY, 36, 0, 100)
      : number(detectedFocus?.heroFocusY, raw.layout?.heroFocusY ?? 36, 0, 100),
    faceCount: detectedFocus?.faceCount ?? 0,
    focusStrategy: detectedFocus?.focusStrategy ?? (manualFaceFocus ? "manual" : "fallback"),
    sessionPanelOpacity: number(raw.layout?.sessionPanelOpacity, 0.6, 0.2, 0.9),
  },
  colors: {
    background: hex(raw.colors?.background || "#080b14", "background"),
    panel: hex(raw.colors?.panel || "#111827", "panel"),
    panelAlt: hex(raw.colors?.panelAlt || "#171f32", "panelAlt"),
    accent,
    accentAlt: hex(raw.colors?.accentAlt || accent, "accentAlt"),
    secondary,
    highlight,
    text: hex(raw.colors?.text || "#fffafc", "text"),
    muted: hex(raw.colors?.muted || "#c7b8c2", "muted"),
    line: `rgba(${Number.parseInt(accent.slice(1, 3), 16)}, ${Number.parseInt(accent.slice(3, 5), 16)}, ${Number.parseInt(accent.slice(5, 7), 16)}, .32)`,
  },
};

await fs.writeFile(path.join(outputDir, "theme.json"), `${JSON.stringify(theme, null, 2)}\n`, { mode: 0o600 });
console.log(JSON.stringify({ pass: true, outputDir, theme }, null, 2));
