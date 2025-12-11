import SwiftUI


struct FramePreview: View {
    @ObservedObject var appState: AppState

    var body: some View {
        GeometryReader { geometry in
            let scale = min(
                geometry.size.width / appState.selectedDevice.cgWidth,
                geometry.size.height / appState.selectedDevice.cgHeight
            ) * 0.9 // 90% scale to leave breathing room

            ZStack {
                // Workspace Background (The "Studio" Desk)
                Color(nsColor: .windowBackgroundColor) // Base
                
                // Subtle Grid Pattern
                Path { path in
                    let step: CGFloat = 40
                    for x in stride(from: 0, to: geometry.size.width, by: step) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    for y in stride(from: 0, to: geometry.size.height, by: step) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.primary.opacity(0.03))
                
                // Vignette-ish radial gradient to focus attention
                RadialGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.1)]),
                    center: .center,
                    startRadius: 200,
                    endRadius: 800
                )

                // The Exportable Frame (Floating on the surface)
                frameContent
                    .frame(width: appState.selectedDevice.cgWidth, height: appState.selectedDevice.cgHeight)
                    .scaleEffect(scale)
                    .shadow(color: .black.opacity(0.35), radius: 30, x: 0, y: 15) // Deep shadow for depth
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }

    var frameContent: some View {
        let width = appState.selectedDevice.cgWidth
        let height = appState.selectedDevice.cgHeight
        let isMac = appState.selectedDevice.id.lowercased().contains("macbook")
        let deviceCornerRadius = isMac ? width * 0.03 : width * 0.04

        return ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [appState.topColor, appState.bottomColor]),
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                // Top Padding (Adaptive based on device)
                Spacer()
                    .frame(height: height * (isMac ? 0.06 : 0.08))

                // Hero Text Area
                VStack(spacing: height * 0.015) {
                    Text(appState.heroText)
                        .font(.system(size: height * 0.045, weight: .heavy, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)

                    if !appState.subtitleText.isEmpty {
                        Text(appState.subtitleText)
                            .font(.system(size: height * 0.022, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .padding(.horizontal, width * 0.1)
                    }
                }
                .frame(height: height * 0.20, alignment: .top)
                
                // Screenshot Area
                ZStack(alignment: .top) {
                    if let nsImage = appState.screenshotImage {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(isMac ? width * 0.02 : deviceCornerRadius) // Screen radius
                            // Custom Frame Overlay
                            .overlay(
                                Group {
                                    if isMac {
                                        // Realistic MacBook Frame Asset
                                        Image("MacBookFrame")
                                            .resizable()
                                            .allowsHitTesting(false) // Let clicks pass through if needed
                                            // The frame image includes bezel and notch, so we stretch it slightly over the content
                                            // Ideally the asset aspect ratio matches. 
                                            // We scale it to fit the content frame + bezel thickness.
                                            .scaleEffect(1.03) // Slight overflow to cover edges
                                    } else {
                                        // Standard Phone/Pad Bezel
                                        RoundedRectangle(cornerRadius: deviceCornerRadius)
                                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                    }
                                }
                            )
                            // Device Outer Border (Hardware feel) - Only for non-Macs now as Mac uses full image
                            .overlay(
                                Group {
                                    if !isMac {
                                        RoundedRectangle(cornerRadius: deviceCornerRadius)
                                            .stroke(
                                                LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), 
                                                lineWidth: 4
                                            )
                                            .blendMode(.overlay)
                                    }
                                }
                            )
                            .shadow(color: .black.opacity(0.4), radius: 50, x: 0, y: 20)
                            .padding(.horizontal, width * 0.08)
                    } else {
                        // Placeholder
                        RoundedRectangle(cornerRadius: deviceCornerRadius)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                VStack(spacing: 20) {
                                    Image(systemName: isMac ? "laptopcomputer" : "plus.viewfinder")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(isMac ? "Select Mac App Screenshot" : "Select Screenshot")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            )
                            .padding(.horizontal, width * 0.08)
                            .frame(height: isMac ? height * 0.5 : height * 0.6) // Adjust aspect for Mac
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .clipped()
    }
}
