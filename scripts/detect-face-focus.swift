#!/usr/bin/swift

import Foundation
import Vision

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: detect-face-focus.swift /path/to/image\n", stderr)
    exit(64)
}

let imageURL = URL(fileURLWithPath: CommandLine.arguments[1])
let request = VNDetectFaceRectanglesRequest()

do {
    let handler = VNImageRequestHandler(url: imageURL, options: [:])
    try handler.perform([request])
    let faces = (request.results ?? []).map(\.boundingBox)

    guard !faces.isEmpty else {
        let data = try JSONSerialization.data(withJSONObject: [
            "pass": true,
            "faceCount": 0,
            "focusStrategy": "fallback"
        ], options: [.sortedKeys])
        print(String(decoding: data, as: UTF8.self))
        exit(0)
    }

    // Vision uses a bottom-left origin. Convert the union to CSS's top-left space.
    let minX = faces.map(\.minX).min()!
    let maxX = faces.map(\.maxX).max()!
    let top = faces.map { 1.0 - $0.maxY }.min()!
    let bottom = faces.map { 1.0 - $0.minY }.max()!

    // Center the whole group horizontally. Vertically, protect the highest head
    // rather than centering the faces: an ultra-wide `cover` crop loses far more
    // image above/below than it loses at the sides.
    let focusX = min(100.0, max(0.0, ((minX + maxX) / 2.0) * 100.0))
    let focusY = min(32.0, max(0.0, top * 100.0 - 4.0))
    let payload: [String: Any] = [
        "pass": true,
        "faceCount": faces.count,
        "focusStrategy": "vision-group-head-safe",
        "heroFocusX": (focusX * 10).rounded() / 10,
        "heroFocusY": (focusY * 10).rounded() / 10,
        "faceUnion": [
            "left": (minX * 1000).rounded() / 10,
            "right": (maxX * 1000).rounded() / 10,
            "top": (top * 1000).rounded() / 10,
            "bottom": (bottom * 1000).rounded() / 10
        ]
    ]
    let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
    print(String(decoding: data, as: UTF8.self))
} catch {
    fputs("Face detection failed: \(error)\n", stderr)
    exit(1)
}
