#!/usr/bin/env swift
// Draws the app icon, the extension icons and the toolbar icons.
// Run from the repository root: swift scripts/generate-icons.swift

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let top = CGColor(srgbRed: 0.33, green: 0.58, blue: 1.0, alpha: 1)
let bottom = CGColor(srgbRed: 0.16, green: 0.36, blue: 0.86, alpha: 1)
let white = CGColor(gray: 1, alpha: 1)
let black = CGColor(gray: 0, alpha: 1)

/// A magnifying glass struck through, drawn in a unit square with y pointing down.
func drawGlyph(in context: CGContext, rect: CGRect, color: CGColor) {
    context.saveGState()
    context.translateBy(x: rect.minX, y: rect.minY)
    context.scaleBy(x: rect.width, y: rect.height)
    context.beginTransparencyLayer(auxiliaryInfo: nil)
    context.setLineCap(.round)
    context.setStrokeColor(color)

    let center = CGPoint(x: 0.42, y: 0.42)
    let radius = 0.25
    context.setLineWidth(0.09)
    context.strokeEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))

    let edge = radius + 0.045
    context.setLineWidth(0.13)
    context.move(to: CGPoint(x: center.x + edge * 0.7071, y: center.y + edge * 0.7071))
    context.addLine(to: CGPoint(x: 0.86, y: 0.86))
    context.strokePath()

    let slashStart = CGPoint(x: 0.14, y: 0.86)
    let slashEnd = CGPoint(x: 0.86, y: 0.14)
    context.setBlendMode(.clear)
    context.setLineWidth(0.2)
    context.move(to: slashStart)
    context.addLine(to: slashEnd)
    context.strokePath()

    context.setBlendMode(.normal)
    context.setLineWidth(0.08)
    context.move(to: slashStart)
    context.addLine(to: slashEnd)
    context.strokePath()

    context.endTransparencyLayer()
    context.restoreGState()
}

func render(size: Int, to path: String, opaque: Bool = false, draw: (CGContext, CGFloat) -> Void) {
    let context = CGContext(
        data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: opaque ? CGImageAlphaInfo.noneSkipLast.rawValue : CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    // Flip so drawing code can use y-down coordinates.
    context.translateBy(x: 0, y: CGFloat(size))
    context.scaleBy(x: 1, y: -1)
    draw(context, CGFloat(size))

    let url = URL(fileURLWithPath: path)
    try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, context.makeImage()!, nil)
    CGImageDestinationFinalize(destination)
}

func drawIcon(_ context: CGContext, size: CGFloat, rounded: Bool) {
    let bounds = CGRect(x: 0, y: 0, width: size, height: size)
    if rounded {
        context.addPath(CGPath(roundedRect: bounds, cornerWidth: size * 0.225, cornerHeight: size * 0.225, transform: nil))
        context.clip()
    }
    let gradient = CGGradient(colorsSpace: nil, colors: [top, bottom] as CFArray, locations: [0, 1])!
    context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size), options: [])
    drawGlyph(in: context, rect: bounds.insetBy(dx: size * 0.2, dy: size * 0.2), color: white)
}

// The system masks the app icon itself, so it is a full opaque square.
render(size: 1024, to: "App/Assets.xcassets/AppIcon.appiconset/AppIcon.png", opaque: true) {
    drawIcon($0, size: $1, rounded: false)
}
render(size: 512, to: "App/Assets.xcassets/AppIconArtwork.imageset/AppIconArtwork.png", opaque: true) {
    drawIcon($0, size: $1, rounded: false)
}

for size in [48, 64, 96, 128, 256, 512] {
    render(size: size, to: "Extension/Resources/images/icon-\(size).png") {
        drawIcon($0, size: $1, rounded: true)
    }
}

// Safari uses the toolbar icon's alpha channel as a template.
for size in [16, 19, 32, 38, 48, 72] {
    render(size: size, to: "Extension/Resources/images/toolbar-icon-\(size).png") { context, size in
        drawGlyph(in: context, rect: CGRect(x: 0, y: 0, width: size, height: size).insetBy(dx: size * 0.06, dy: size * 0.06), color: black)
    }
}
