import Foundation
import AppKit
import CoreGraphics
import CoreText

// MARK: - Frame Generator Errors

public enum FrameGeneratorError: Error, LocalizedError {
    case templateNotFound(String)
    case deviceNotFound(String)
    case screenshotNotFound(String)
    case screenshotLoadFailed(String)
    case renderingFailed
    case saveFailed(String)

    public var errorDescription: String? {
        switch self {
        case .templateNotFound(let id):
            return "Template not found: \(id)"
        case .deviceNotFound(let id):
            return "Device size not found: \(id)"
        case .screenshotNotFound(let path):
            return "Screenshot file not found: \(path)"
        case .screenshotLoadFailed(let path):
            return "Failed to load screenshot: \(path)"
        case .renderingFailed:
            return "Failed to render frame"
        case .saveFailed(let path):
            return "Failed to save frame to: \(path)"
        }
    }
}

// MARK: - Frame Generator

public class FrameGenerator {

    public init() {}

    // MARK: - Main Generation Method

    public func generateFrame(
        screenshotPath: String,
        heroText: String,
        subtitle: String? = nil,
        templateId: String,
        deviceId: String = "iphone_6.7",
        outputPath: String
    ) throws {
        // Validate inputs
        guard let template = GradientTemplate.find(byId: templateId) else {
            throw FrameGeneratorError.templateNotFound(templateId)
        }

        guard let device = DeviceSize.find(byId: deviceId) else {
            throw FrameGeneratorError.deviceNotFound(deviceId)
        }

        let screenshotURL = URL(fileURLWithPath: screenshotPath)
        guard FileManager.default.fileExists(atPath: screenshotPath) else {
            throw FrameGeneratorError.screenshotNotFound(screenshotPath)
        }

        guard let screenshot = NSImage(contentsOf: screenshotURL) else {
            throw FrameGeneratorError.screenshotLoadFailed(screenshotPath)
        }

        // Generate the frame
        let frameImage = try renderFrame(
            screenshot: screenshot,
            heroText: heroText,
            subtitle: subtitle,
            template: template,
            device: device
        )

        // Save to file at exact pixel dimensions
        try saveImage(frameImage, to: outputPath, targetWidth: device.width, targetHeight: device.height)
    }

    // MARK: - Batch Generation

    public func generateBatch(
        frames: [[String: String]],
        deviceId: String = "iphone_6.7"
    ) throws -> [String] {
        var outputPaths: [String] = []

        for frame in frames {
            guard let screenshotPath = frame["screenshot_path"],
                  let heroText = frame["hero_text"],
                  let templateId = frame["template"],
                  let outputPath = frame["output_path"] else {
                continue
            }

            let subtitle = frame["subtitle"]

            try generateFrame(
                screenshotPath: screenshotPath,
                heroText: heroText,
                subtitle: subtitle,
                templateId: templateId,
                deviceId: deviceId,
                outputPath: outputPath
            )

            outputPaths.append(outputPath)
        }

        return outputPaths
    }

    // MARK: - List Templates

    public func listTemplates() -> [[String: String]] {
        GradientTemplate.allTemplates.map { template in
            [
                "id": template.id,
                "name": template.name,
                "topColor": template.topColorHex,
                "bottomColor": template.bottomColorHex
            ]
        }
    }

    // MARK: - Rendering

    private func renderFrame(
        screenshot: NSImage,
        heroText: String,
        subtitle: String?,
        template: GradientTemplate,
        device: DeviceSize
    ) throws -> NSImage {
        let width = CGFloat(device.width)
        let height = CGFloat(device.height)

        let image = NSImage(size: NSSize(width: width, height: height))

        image.lockFocus()

        guard let context = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            throw FrameGeneratorError.renderingFailed
        }

        // 1. Draw gradient background
        drawGradient(context: context, width: width, height: height, template: template)

        // 2. Calculate text sizes first to determine dynamic layout
        let topPadding = height * 0.06
        let heroFontSize = height * 0.042
        let subtitleFontSize = height * 0.022
        let textSpacing = height * 0.015
        let textToScreenshotGap = height * 0.025

        // 3. Draw hero text
        let heroStartY = height - topPadding
        let heroBottomY = drawCenteredText(
            context: context,
            text: heroText,
            fontSize: heroFontSize,
            bold: true,
            color: .white,
            y: heroStartY,
            width: width,
            maxWidth: width * 0.88
        )

        // 4. Draw subtitle if present
        var textBottomY = heroBottomY
        if let subtitle = subtitle, !subtitle.isEmpty {
            textBottomY = drawCenteredText(
                context: context,
                text: subtitle,
                fontSize: subtitleFontSize,
                bold: false,
                color: NSColor.white.withAlphaComponent(0.8),
                y: heroBottomY - textSpacing,
                width: width,
                maxWidth: width * 0.88
            )
        }

        // 5. Draw screenshot - position dynamically below text
        let screenshotTopY = height - textBottomY + textToScreenshotGap
        let screenshotMaxWidth = width * 0.88
        let screenshotMaxHeight = textBottomY - textToScreenshotGap - (height * 0.03)
        let cornerRadius = width * 0.035

        drawScreenshot(
            context: context,
            screenshot: screenshot,
            x: width * 0.06,
            topY: screenshotTopY,
            maxWidth: screenshotMaxWidth,
            maxHeight: screenshotMaxHeight,
            cornerRadius: cornerRadius,
            frameHeight: height
        )

        image.unlockFocus()

        return image
    }

    // MARK: - Text Measurement

    private func measureTextHeight(
        text: String,
        fontSize: CGFloat,
        bold: Bool,
        maxWidth: CGFloat
    ) -> CGFloat {
        let font: NSFont = bold ? NSFont.boldSystemFont(ofSize: fontSize) : NSFont.systemFont(ofSize: fontSize)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.boundingRect(
            with: NSSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )

        return textSize.height
    }

    // MARK: - Drawing Helpers

    private func drawGradient(context: CGContext, width: CGFloat, height: CGFloat, template: GradientTemplate) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [template.topColor.cgColor, template.bottomColor.cgColor] as CFArray
        let locations: [CGFloat] = [0.0, 1.0]

        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) else {
            return
        }

        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: width / 2, y: height),
            end: CGPoint(x: width / 2, y: 0),
            options: []
        )
    }

    @discardableResult
    private func drawCenteredText(
        context: CGContext,
        text: String,
        fontSize: CGFloat,
        bold: Bool,
        color: NSColor,
        y: CGFloat,
        width: CGFloat,
        maxWidth: CGFloat
    ) -> CGFloat {
        let font: NSFont
        if bold {
            font = NSFont.boldSystemFont(ofSize: fontSize)
        } else {
            font = NSFont.systemFont(ofSize: fontSize)
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
        shadow.shadowOffset = NSSize(width: 0, height: -2)
        shadow.shadowBlurRadius = 4

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            .shadow: shadow
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.boundingRect(
            with: NSSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )

        let x = (width - textSize.width) / 2
        let rect = NSRect(x: x, y: y - textSize.height, width: textSize.width, height: textSize.height)

        attributedString.draw(in: rect)

        return y - textSize.height
    }

    private func drawScreenshot(
        context: CGContext,
        screenshot: NSImage,
        x: CGFloat,
        topY: CGFloat,
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        cornerRadius: CGFloat,
        frameHeight: CGFloat
    ) {
        let imageSize = screenshot.size
        let aspectRatio = imageSize.width / imageSize.height

        var drawWidth = maxWidth
        var drawHeight = drawWidth / aspectRatio

        if drawHeight > maxHeight {
            drawHeight = maxHeight
            drawWidth = drawHeight * aspectRatio
        }

        let drawX = x + (maxWidth - drawWidth) / 2
        let drawY = frameHeight - topY - drawHeight

        let drawRect = NSRect(x: drawX, y: drawY, width: drawWidth, height: drawHeight)

        // Draw shadow first
        context.saveGState()
        context.setShadow(offset: CGSize(width: 0, height: -10), blur: 40, color: NSColor.black.withAlphaComponent(0.25).cgColor)

        let shadowPath = NSBezierPath(roundedRect: drawRect, xRadius: cornerRadius, yRadius: cornerRadius)
        NSColor.black.withAlphaComponent(0.01).setFill()
        shadowPath.fill()

        context.restoreGState()

        // Draw screenshot with rounded corners
        context.saveGState()

        let clipPath = NSBezierPath(roundedRect: drawRect, xRadius: cornerRadius, yRadius: cornerRadius)
        clipPath.addClip()

        screenshot.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1.0)

        context.restoreGState()
    }

    // MARK: - Save Image

    private func saveImage(_ image: NSImage, to path: String, targetWidth: Int, targetHeight: Int) throws {
        // Create bitmap at exact pixel dimensions (force 1x, ignore Retina scaling)
        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: targetWidth,
            pixelsHigh: targetHeight,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            throw FrameGeneratorError.saveFailed(path)
        }

        // Draw into the bitmap at exact size
        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: bitmapRep)
        NSGraphicsContext.current = context

        let targetRect = NSRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
        image.draw(in: targetRect, from: .zero, operation: .copy, fraction: 1.0)

        NSGraphicsContext.restoreGraphicsState()

        // Save as PNG
        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            throw FrameGeneratorError.saveFailed(path)
        }

        let url = URL(fileURLWithPath: path)

        // Create directory if needed
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        do {
            try pngData.write(to: url)
        } catch {
            throw FrameGeneratorError.saveFailed(path)
        }
    }
}
