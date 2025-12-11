import Foundation
import AppKit

// MARK: - Gradient Template

public struct GradientTemplate: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let topColorHex: String
    public let bottomColorHex: String

    public init(id: String = UUID().uuidString, name: String, topColorHex: String, bottomColorHex: String) {
        self.id = id
        self.name = name
        self.topColorHex = topColorHex
        self.bottomColorHex = bottomColorHex
    }

    public var topColor: NSColor {
        NSColor(hex: topColorHex)
    }

    public var bottomColor: NSColor {
        NSColor(hex: bottomColorHex)
    }

    public static let allTemplates: [GradientTemplate] = [
        GradientTemplate(id: "ocean", name: "Ocean", topColorHex: "#0F2027", bottomColorHex: "#2C5364"),
        GradientTemplate(id: "sunset", name: "Sunset", topColorHex: "#F37335", bottomColorHex: "#FDC830"),
        GradientTemplate(id: "forest", name: "Forest", topColorHex: "#134E5E", bottomColorHex: "#71B280"),
        GradientTemplate(id: "midnight", name: "Midnight", topColorHex: "#232526", bottomColorHex: "#414345"),
        GradientTemplate(id: "berry", name: "Berry", topColorHex: "#8E2DE2", bottomColorHex: "#4A00E0"),
        GradientTemplate(id: "coral", name: "Coral", topColorHex: "#FF416C", bottomColorHex: "#FF4B2B"),
        GradientTemplate(id: "mint", name: "Mint", topColorHex: "#00B09B", bottomColorHex: "#96C93D"),
        GradientTemplate(id: "slate", name: "Slate", topColorHex: "#2C3E50", bottomColorHex: "#4CA1AF"),
        GradientTemplate(id: "dawn", name: "Dawn", topColorHex: "#C33764", bottomColorHex: "#1D2671"),
        GradientTemplate(id: "sand", name: "Sand", topColorHex: "#C9B37E", bottomColorHex: "#9D8858")
    ]

    public static func find(byId id: String) -> GradientTemplate? {
        allTemplates.first { $0.id.lowercased() == id.lowercased() }
    }
}

// MARK: - Device Size

public struct DeviceSize: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let width: Int
    public let height: Int

    public init(id: String, name: String, width: Int, height: Int) {
        self.id = id
        self.name = name
        self.width = width
        self.height = height
    }

    public var cgSize: CGSize {
        CGSize(width: width, height: height)
    }

    public static let allSizes: [DeviceSize] = [
        DeviceSize(id: "iphone_6.7", name: "iPhone 6.7\" (1290 x 2796)", width: 1290, height: 2796),
        DeviceSize(id: "iphone_6.5", name: "iPhone 6.5\" (1284 x 2778)", width: 1284, height: 2778),
        DeviceSize(id: "iphone_5.5", name: "iPhone 5.5\" (1242 x 2208)", width: 1242, height: 2208),
        DeviceSize(id: "ipad_12.9", name: "iPad 12.9\" (2048 x 2732)", width: 2048, height: 2732),
        DeviceSize(id: "ipad_13", name: "iPad Pro 13\" (2064 x 2752)", width: 2064, height: 2752)
    ]

    public static func find(byId id: String) -> DeviceSize? {
        allSizes.first { $0.id.lowercased() == id.lowercased() }
    }
}

// MARK: - NSColor Extension

extension NSColor {
    public convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }

    public var hexString: String {
        guard let rgb = usingColorSpace(.sRGB) else { return "#000000" }
        let r = Int(rgb.redComponent * 255)
        let g = Int(rgb.greenComponent * 255)
        let b = Int(rgb.blueComponent * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
