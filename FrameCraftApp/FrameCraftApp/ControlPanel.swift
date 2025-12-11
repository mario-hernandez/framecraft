import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ControlPanel: View {
    @ObservedObject var appState: AppState
    @State private var showMCPInfo = false

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

                        Button(action: selectImage) {
                            HStack {
                                Image(systemName: "photo")
                                Text(appState.screenshotImage == nil ? "Select Screenshot..." : "Change Screenshot")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        if appState.screenshotImage == nil {
                            Text("Select a screenshot to export")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Button(action: exportImage) {
                                Label("Export Frame", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(4)
                }
                
                Divider()

                // MCP Integration (Pro)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "terminal.fill")
                        Text("MCP Server")
                            .font(.headline)
                    }
                    
                    Text("Connect FrameCraft to Claude Code using the Model Context Protocol.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button {
                        showMCPInfo = true
                    } label: {
                        Text("Setup MCP Integration")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.regular)
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .frame(minWidth: 320, maxWidth: 400)
        .sheet(isPresented: $showMCPInfo) {
            MCPSetupView()
        }
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
}

struct MCPSetupView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "terminal.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
                .padding(.top)
            
            VStack(spacing: 8) {
                Text("Automate with Claude")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("FrameCraft supports the Model Context Protocol (MCP), allowing you to generate frames directly from Claude Code.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lock.shield")
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Separate Installation Required")
                            .font(.headline)
                        Text("Due to App Store security rules (Sandboxing), the MCP server must be installed separately via Terminal or Homebrew/Swift.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Link(destination: URL(string: "https://github.com/mario-hernandez/framecraft")!) {
                    HStack {
                        Text("View Installation Guide")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.up.right.square")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.secondary)
            }
        }
        .frame(width: 450, height: 450)
        .padding(32)
    }
}
