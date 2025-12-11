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
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }
}
