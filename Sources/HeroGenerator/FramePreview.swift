import SwiftUI
import FrameCraftCore

struct FramePreview: View {
    @ObservedObject var appState: AppState

    var body: some View {
        GeometryReader { geometry in
            let scale = min(
                geometry.size.width / appState.selectedDevice.cgWidth,
                geometry.size.height / appState.selectedDevice.cgHeight
            )

            ZStack {
                // Background
                Color.gray.opacity(0.2)

                // The Frame
                frameContent
                    .frame(width: appState.selectedDevice.cgWidth, height: appState.selectedDevice.cgHeight)
                    .scaleEffect(scale)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }

    var frameContent: some View {
        let width = appState.selectedDevice.cgWidth
        let height = appState.selectedDevice.cgHeight

        return ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [appState.topColor, appState.bottomColor]),
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                // Top Padding (approx 5% of height)
                Spacer()
                    .frame(height: height * 0.05)

                // Hero Text Area (22% of height)
                VStack(spacing: height * 0.01) {
                    Text(appState.heroText)
                        .font(.system(size: height * 0.05, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)

                    if !appState.subtitleText.isEmpty {
                        Text(appState.subtitleText)
                            .font(.system(size: height * 0.025, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    }
                }
                .frame(height: height * 0.22, alignment: .top)
                .padding(.horizontal, width * 0.05)

                // Screenshot Area
                if let nsImage = appState.screenshotImage {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(width * 0.03)
                        .shadow(color: .black.opacity(0.25), radius: 40, x: 0, y: 0)
                        .padding(.horizontal, width * 0.05)
                        .frame(maxHeight: .infinity, alignment: .top)
                } else {
                    // Placeholder
                    RoundedRectangle(cornerRadius: width * 0.03)
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            Text("Select Screenshot")
                                .foregroundColor(.white)
                                .font(.title)
                        )
                        .padding(.horizontal, width * 0.05)
                        .frame(maxHeight: .infinity, alignment: .top)
                }

                // Bottom Padding
                Spacer()
                    .frame(height: height * 0.08)
            }
        }
        .clipped()
    }
}
