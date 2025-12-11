import SwiftUI
import AppKit
import Combine

class AppState: ObservableObject {
    @Published var selectedTemplate: GradientTemplate = GradientTemplate.allTemplates[0]
    @Published var selectedDevice: DeviceSize = DeviceSize.allSizes[0]
    @Published var heroText: String = "Hero Text"
    @Published var subtitleText: String = "Subtitle goes here"
    @Published var screenshotImage: NSImage? = nil
    @Published var customTopColor: Color = .blue
    @Published var customBottomColor: Color = .purple
    @Published var isCustomGradient: Bool = false

    var topColor: Color {
        isCustomGradient ? customTopColor : selectedTemplate.topSwiftUIColor
    }

    var bottomColor: Color {
        isCustomGradient ? customBottomColor : selectedTemplate.bottomSwiftUIColor
    }
}
