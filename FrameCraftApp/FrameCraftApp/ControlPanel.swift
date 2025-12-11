import SwiftUI
import AppKit
import UniformTypeIdentifiers
// import FrameCraftCore

// MARK: - Premium UI Components

struct PremiumTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.leading, 2)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isFocused ? Color.accentColor.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: isFocused ? Color.accentColor.opacity(0.2) : .clear, radius: 4)
                
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .focused($isFocused)
            }
            .frame(height: 32)
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5) // Kerning
                .foregroundColor(.secondary)
        }
        .padding(.leading, 4)
        .padding(.top, 4)
    }
}

// MARK: - Main Control Panel

struct ControlPanel: View {
    @ObservedObject var appState: AppState
    @State private var showMCPInfo = false
    @State private var isDragging = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) { // Increased spacing
                // MARK: - Header
                HStack(alignment: .center, spacing: 14) {
                    Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                        .resizable()
                        .frame(width: 52, height: 52)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("FrameCraft")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("Professional Suite")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 4)

                // MARK: - Input Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "SOURCE", icon: "photo.on.rectangle.angled")

                    Button {
                        selectImage()
                    } label: {
                        ZStack {
                            // Background Card using Materials
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Material.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                        .foregroundColor(appState.screenshotImage == nil ? .secondary.opacity(0.3) : .green.opacity(0.5))
                                )
                            
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(appState.screenshotImage == nil ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: appState.screenshotImage == nil ? "plus" : "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(appState.screenshotImage == nil ? .blue : .green)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(appState.screenshotImage == nil ? "Select Screenshot" : "Image Loaded")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text(appState.screenshotImage == nil ? "Drag & drop or click" : "Click to replace")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(12)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(height: 60)
                    .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                        if let provider = providers.first {
                            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (urlData, error) in
                                DispatchQueue.main.async {
                                    if let urlData = urlData as? Data,
                                       let url = URL(dataRepresentation: urlData, relativeTo: nil),
                                       let image = NSImage(contentsOf: url) {
                                        appState.screenshotImage = image
                                    }
                                }
                            }
                            return true
                        }
                        return false
                    }
                }

                // MARK: - Content Section
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "CONTENT", icon: "text.quote")

                    VStack(spacing: 14) {
                        PremiumTextField(label: "HERO TEXT", placeholder: "Make it pop...", text: $appState.heroText)
                        PremiumTextField(label: "SUBTITLE", placeholder: "Add some context...", text: $appState.subtitleText)
                    }
                    .padding(12)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                             .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                }

                // MARK: - Style Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "STYLE & DEVICE", icon: "paintpalette.fill")

                    VStack(spacing: 0) {
                        // Template Picker Row
                        HStack {
                            Label {
                                Text("Template")
                                    .font(.system(size: 13, weight: .medium))
                            } icon: {
                                Image(systemName: "swatchpalette")
                                    .foregroundColor(.purple)
                            }
                            Spacer()
                            Picker("", selection: $appState.selectedTemplate) {
                                ForEach(GradientTemplate.allTemplates) { template in
                                    Text(template.name).tag(template)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 140)
                        }
                        .padding(10)
                        
                        Divider().padding(.horizontal, 10).opacity(0.3)

                        // Device Picker Row
                        HStack {
                            Label {
                                Text("Device")
                                    .font(.system(size: 13, weight: .medium))
                            } icon: {
                                Image(systemName: "iphone.gen3")
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Picker("", selection: $appState.selectedDevice) {
                                ForEach(DeviceSize.allSizes) { size in
                                    Text(size.name).tag(size)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 140)
                        }
                        .padding(10)
                    }
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                             .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                }

                Spacer(minLength: 20)

                // MARK: - Actions
                VStack(spacing: 16) {
                    Button(action: exportImage) {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 16))
                            Text("Export Asset")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(0.5)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(appState.screenshotImage == nil)
                    .opacity(appState.screenshotImage == nil ? 0.6 : 1.0)
                    .keyboardShortcut(.defaultAction)

                    Button {
                        showMCPInfo = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "terminal.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Text("MCP AUTOMATION")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Color(nsColor: .windowBackgroundColor)) // Match seamless look
        .sheet(isPresented: $showMCPInfo) {
            MCPSetupView(show: $showMCPInfo)
        }
    }
    
    // Logic extraction for cleaner body
    func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            if let image = NSImage(contentsOf: url) {
                appState.screenshotImage = image
            }
        }
    }

    func exportImage() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "Frame_\(appState.selectedTemplate.name).png"
        
        if panel.runModal() == .OK, let url = panel.url {
            let renderer = ImageRenderer(content: FramePreview(appState: appState).frameContent)
            renderer.scale = 2.0 // Retina export
            
            if let nsImage = renderer.nsImage {
                if let tiffData = nsImage.tiffRepresentation,
                   let bitmapImage = NSBitmapImageRep(data: tiffData),
                   let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                    try? pngData.write(to: url)
                }
            }
        }
    }
}

// Helper for Preview
struct PremiumControlPanel_Previews: PreviewProvider {
    static var previews: some View {
        ControlPanel(appState: AppState())
            .frame(width: 300, height: 800)
    }
}

// MARK: - Setup View
// MARK: - Setup View
struct MCPSetupView: View {
    @Binding var show: Bool
    @State private var copied = false
    
    let magicPrompt = """
    I want to use FrameCraft to automate screenshot framing.
    Please help me install the 'framecraft-mcp' server using Homebrew.
    The formula is: brew install mario-hernandez/framecraft/framecraft-mcp
    Once installed, please guide me on how to configure you (Claude) to use it.
    """
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cpu.fill")
                .font(.system(size: 42))
                .foregroundColor(.accentColor)
                .padding(.top, 20)
                .shadow(color: .accentColor.opacity(0.3), radius: 10)
            
            VStack(spacing: 6) {
                Text("Automate with AI")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Let Claude generate hundreds of assets for you.\nNo coding required.")
                    .font(.system(size: 13))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                // Magic Prompt Button
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(magicPrompt, forType: .string)
                    withAnimation {
                        copied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        copied = false
                    }
                } label: {
                    HStack {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc.fill")
                        Text(copied ? "Copied to Clipboard!" : "Copy Setup Prompt for Claude")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Text("Paste this into Claude Desktop to start.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Link(destination: URL(string: "https://mario-hernandez.github.io/framecraft/setup.html")!) {
                    HStack {
                        Text("View Manual Instructions")
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(size: 12))
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button("Done") {
                show = false
            }
            .keyboardShortcut(.defaultAction)
            .padding(.bottom, 20)
        }
        .frame(width: 380, height: 380)
        .background(Material.regular)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
