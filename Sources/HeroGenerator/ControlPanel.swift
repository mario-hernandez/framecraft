import SwiftUI
import AppKit
import FrameCraftCore

struct ControlPanel: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("FrameCraft")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("App Store Frame Generator")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)

                Divider()

                // Configuration Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Configuration")
                        .font(.headline)
                    
                    // Screenshot Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Screenshot Source")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button {
                                selectImage()
                            } label: {
                                HStack {
                                    Image(systemName: "photo")
                                    Text(appState.screenshotImage == nil ? "Select Screenshot..." : "Change Screenshot")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .controlSize(.large)
                        }
                        
                        if appState.screenshotImage != nil {
                            Label("Image Loaded Successfully", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }

                    // Device Size
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Device")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $appState.selectedDevice) {
                            ForEach(DeviceSize.allSizes) { size in
                                Text(size.name).tag(size)
                            }
                        }
                        .labelsHidden()
                    }
                }

                Divider()

                // Content Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Content")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hero Text")
                                .font(.caption)
                            TextField("Enter catchy title", text: $appState.heroText)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Subtitle")
                                .font(.caption)
                            TextField("Enter description", text: $appState.subtitleText)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }

                Divider()

                // Style Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Style")
                        .font(.headline)
                    
                    Picker("Template", selection: $appState.selectedTemplate) {
                        ForEach(GradientTemplate.allTemplates) { template in
                            HStack {
                                Circle()
                                    .fill(LinearGradient(colors: [template.topSwiftUIColor, template.bottomSwiftUIColor], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 12, height: 12)
                                Text(template.name)
                            }
                            .tag(template)
                        }
                    }
                    .onChange(of: appState.selectedTemplate) {
                        appState.isCustomGradient = false
                    }

                    Toggle("Custom Gradient", isOn: $appState.isCustomGradient)
                        .font(.caption)

                    if appState.isCustomGradient {
                        HStack {
                            ColorPicker("Top", selection: $appState.customTopColor)
                            ColorPicker("Bottom", selection: $appState.customBottomColor)
                        }
                    }
                }

                Spacer()

                // Footer Actions
                VStack(spacing: 12) {
                    Button(action: exportImage) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Frame")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .disabled(appState.screenshotImage == nil)
                    
                    if appState.screenshotImage == nil {
                        Text("Select a screenshot to export")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(24)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .frame(minWidth: 320, maxWidth: 400)
    }

    func selectImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg]

        if panel.runModal() == .OK {
            if let url = panel.url, let image = NSImage(contentsOf: url) {
                appState.screenshotImage = image
            }
        }
    }

    @MainActor
    func exportImage() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "AppStoreFrame.png"

        if panel.runModal() == .OK, let url = panel.url {
            // Create a renderer for the frame content at the exact size
            let renderer = ImageRenderer(content:
                FramePreview(appState: appState).frameContent
                    .frame(width: appState.selectedDevice.cgWidth, height: appState.selectedDevice.cgHeight)
            )

            // Important: Set scale to 1.0 to match exact pixel dimensions
            renderer.scale = 1.0

            if let cgImage = renderer.cgImage {
                let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
                if let data = bitmapRep.representation(using: .png, properties: [:]) {
                    try? data.write(to: url)
                }
            }
        }
    }

    func copyMCPPath() {
        // Get the path to the CLI tool embedded in the app bundle
        if let bundlePath = Bundle.main.executablePath {
            let appPath = URL(fileURLWithPath: bundlePath).deletingLastPathComponent()
            let cliPath = appPath.appendingPathComponent("framecraft-mcp").path

            let config = """
            {
              "framecraft": {
                "command": "\(cliPath)",
                "args": []
              }
            }
            """

            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(config, forType: .string)
        }
    }
}
