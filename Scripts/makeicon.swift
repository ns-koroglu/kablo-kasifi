#!/usr/bin/env swift
// Kablo Kaşifi simgesi. Kullanım: swift Scripts/makeicon.swift out.png
import AppKit

let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon.png"
let S: CGFloat = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(S), pixelsHigh: Int(S),
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext

// Arka plan
let inset: CGFloat = S * 0.06
let bg = CGRect(x: inset, y: inset, width: S - inset * 2, height: S - inset * 2)
ctx.saveGState()
ctx.addPath(CGPath(roundedRect: bg, cornerWidth: S * 0.225, cornerHeight: S * 0.225, transform: nil))
ctx.clip()
let colors = [NSColor(calibratedRed: 0.16, green: 0.24, blue: 0.55, alpha: 1).cgColor,
              NSColor(calibratedRed: 0.10, green: 0.52, blue: 0.62, alpha: 1).cgColor] as CFArray
let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: S), end: CGPoint(x: S, y: 0), options: [])
ctx.restoreGState()

// Kablo (aşağıdan gelen eğri)
ctx.saveGState()
ctx.setLineCap(.round)
ctx.setLineWidth(S * 0.075)
ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.9).cgColor)
ctx.move(to: CGPoint(x: S * 0.5, y: S * 0.40))
ctx.addCurve(to: CGPoint(x: S * 0.80, y: S * 0.16),
             control1: CGPoint(x: S * 0.50, y: S * 0.22),
             control2: CGPoint(x: S * 0.66, y: S * 0.16))
ctx.strokePath()

// USB-C fiş gövdesi
let plug = CGRect(x: S * 0.5 - S * 0.135, y: S * 0.38, width: S * 0.27, height: S * 0.20)
ctx.setFillColor(NSColor.white.cgColor)
ctx.addPath(CGPath(roundedRect: plug, cornerWidth: S * 0.10, cornerHeight: S * 0.10, transform: nil))
ctx.fillPath()
// Fiş içi boşluk
let slot = plug.insetBy(dx: S * 0.055, dy: S * 0.055)
ctx.setFillColor(NSColor(calibratedRed: 0.12, green: 0.30, blue: 0.52, alpha: 1).cgColor)
ctx.addPath(CGPath(roundedRect: slot, cornerWidth: S * 0.03, cornerHeight: S * 0.03, transform: nil))
ctx.fillPath()
ctx.restoreGState()

// Büyüteç
ctx.saveGState()
let lensCenter = CGPoint(x: S * 0.60, y: S * 0.63)
let lensR = S * 0.20
ctx.setLineWidth(S * 0.055)
ctx.setStrokeColor(NSColor(calibratedRed: 1.0, green: 0.82, blue: 0.30, alpha: 1).cgColor)
ctx.setFillColor(NSColor.white.withAlphaComponent(0.22).cgColor)
ctx.addEllipse(in: CGRect(x: lensCenter.x - lensR, y: lensCenter.y - lensR, width: lensR * 2, height: lensR * 2))
ctx.drawPath(using: .fillStroke)
ctx.setLineCap(.round)
ctx.move(to: CGPoint(x: lensCenter.x - lensR * 0.72, y: lensCenter.y - lensR * 0.72))
ctx.addLine(to: CGPoint(x: S * 0.30, y: S * 0.33))
ctx.strokePath()
// Parlama
ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.8).cgColor)
ctx.setLineWidth(S * 0.022)
ctx.addArc(center: lensCenter, radius: lensR * 0.62, startAngle: .pi * 0.55, endAngle: .pi * 0.95, clockwise: false)
ctx.strokePath()
ctx.restoreGState()

NSGraphicsContext.restoreGraphicsState()
guard let data = rep.representation(using: .png, properties: [:]) else { exit(1) }
try! data.write(to: URL(fileURLWithPath: outPath))
print("yazıldı: \(outPath)")
