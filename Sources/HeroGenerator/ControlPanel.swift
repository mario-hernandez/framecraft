import SwiftUI
import AppKit
import FrameCraftCore

struct ControlPanel: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("FrameCraft")
                        .font(.headline)
                    Spacer()
                }
                .padding(.bottom, 10)

                // Image Picker
                GroupBox(label: Text("Screenshot")) {
                    HStack {
                        Button("Choose Image...") {
                            selectImage()
                        }
                        if appState.screenshotImage != nil {
                            Text("Image Loaded")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    .padding(5)
                }

                // Text Inputs
                GroupBox(label: Text("Text")) {
                    VStack(alignment: .leading) {
                        TextField("Hero Text", text: $appState.heroText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Subtitle", text: $appState.subtitleText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(5)
                }

                // Template Selection
                GroupBox(label: Text("Template")) {
                    VStack(alignment: .leading) {
                        Picker("Preset", selection: $appState.selectedTemplate) {
                            ForEach(GradientTemplate.allTemplates) { template in
                                Text(template.name).tag(template)
                            }
                        }
                        .onChange(of: appState.selectedTemplate) {
                            appState.isCustomGradient = false
                        }

                        Toggle("Custom Gradient", isOn: $appState.isCustomGradient)

                        if appState.isCustomGradient {
                            ColorPicker("Top Color", selection: $appState.customTopColor)
                            ColorPicker("Bottom Color", selection: $appState.customBottomColor)
                        }
                    }
                    .padding(5)
                }

                // Size Selection
                GroupBox(label: Text("Dimensions")) {
                    Picker("Device", selection: $appState.selectedDevice) {
                        ForEach(DeviceSize.allSizes) { size in
                            Text(size.name).tag(size)
                        }
                    }
                    .padding(5)
                }

                // Export
                GroupBox(label: Text("Export")) {
                    Button(action: exportImage) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export PNG")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .padding(5)
                }

                // MCP Info
                GroupBox(label: Text("MCP Integration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Para usar con Claude Code:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("framecraft-mcp")
                            .font(.system(.caption, design: .monospaced))
                            .padding(4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)

                        Button("Copy CLI Path") {
                            copyMCPPath()
                        }
                        .font(.caption)
                    }
                    .padding(5)
                }

                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 300, maxWidth: 400)
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
