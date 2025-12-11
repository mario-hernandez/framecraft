import SwiftUI


struct ContentView: View {
    @StateObject var appState = AppState()

    var body: some View {
        HSplitView {
            ControlPanel(appState: appState)
                .frame(minWidth: 300, maxWidth: 400)

            FramePreview(appState: appState)
                .frame(minWidth: 400, minHeight: 400)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

@main
struct FrameCraftApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandMenu("App Store") {
                Button("Resize to 1280x800 (1x)") {
                    resizeWindow(width: 1280, height: 800)
                }
                .keyboardShortcut("1", modifiers: [.command, .option])
                
                Button("Resize to 1440x900 (1x)") {
                    resizeWindow(width: 1440, height: 900)
                }
                .keyboardShortcut("2", modifiers: [.command, .option])
                
                Button("Resize to 2560x1600 (2x Retina)") {
                    resizeWindow(width: 2560, height: 1600)
                }
                .keyboardShortcut("3", modifiers: [.command, .option])
            }
        }
    }
    
    private func resizeWindow(width: CGFloat, height: CGFloat) {
        DispatchQueue.main.async {
            guard let window = NSApp.windows.first else { return }
            // Center the window roughly
            let screenFrame = window.screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
            let newX = screenFrame.midX - (width / 2)
            let newY = screenFrame.midY - (height / 2)
            
            let frame = NSRect(x: newX, y: newY, width: width, height: height)
            window.setFrame(frame, display: true, animate: true)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }
}
