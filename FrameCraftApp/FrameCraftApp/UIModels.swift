import SwiftUI


// MARK: - SwiftUI Extensions for Core Models

extension GradientTemplate {
    /// SwiftUI Color for top of gradient
    var topSwiftUIColor: Color {
        Color(nsColor: topColor)
    }

    /// SwiftUI Color for bottom of gradient
    var bottomSwiftUIColor: Color {
        Color(nsColor: bottomColor)
    }
}

extension DeviceSize {
    /// CGFloat width for SwiftUI
    var cgWidth: CGFloat {
        CGFloat(width)
    }

    /// CGFloat height for SwiftUI
    var cgHeight: CGFloat {
        CGFloat(height)
    }
}

// MARK: - SwiftUI Color Extension

extension Color {
    init(hex: String) {
        self.init(nsColor: NSColor(hex: hex))
    }
}
