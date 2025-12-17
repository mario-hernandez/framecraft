<div align="center">

# FrameCraft
### Professional App Store Assets, Zero Friction.

[![Download on Mac App Store](https://img.shields.io/badge/Download_on_the-Mac_App_Store-black?style=flat-square&logo=apple)](https://apps.apple.com/app/framecraft-screenshot-studio/id6756393688)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat-square&logo=swift)
![Platform](https://img.shields.io/badge/Platform-macOS_14+-lightgrey.svg?style=flat-square&logo=apple)
![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)
[![MCP Ready](https://img.shields.io/badge/MCP-Ready-green?style=flat-square&logo=anthropic)](https://modelcontextprotocol.io)

<p align="center">
  <strong>FrameCraft</strong> turns raw simulator screenshots into stunning, Apple Design Award-worthy marketing assets. 
  <br>
  Available as a <strong>native macOS App</strong> for visual editing and a <strong>CLI/MCP Server</strong> for AI automation.
</p>

[Download on Mac App Store](https://apps.apple.com/app/framecraft-screenshot-studio/id6756393688) • [Automation Guide](https://mario-hernandez.github.io/framecraft/setup.html)

</div>

---

## ✨ Why FrameCraft?

Creating App Store screenshots is usually a pain. You need Photoshop, templates, or expensive subscription tools. FrameCraft solves this with a "hyper-premium" native experience that runs 100% offline.

- **Studio Quality**: Automatic device framing, realistic shadows, and professional gradients.
- **Developer First**: Built with SwiftUI for macOS. Fast, lightweight, and scriptable.
- **AI Powered**: Includes the first-ever **MCP Server** for screenshot generation, allowing you to use Claude to build your assets.

## 🚀 Two Ways to Use

### 1. The Visual Studio (GUI)
Perfect for tweaking designs and previewing changes in real-time.

1. **Launch App**: Open `FrameCraft.app`.
2. **Drop**: Drag your simulator screenshot onto the studio area.
3. **Style**: Choose from curated templates like *Ocean*, *Midnight*, or *Minimal*.
4. **Export**: Get a 4K, App Store-ready PNG in one click.

### 2. The Automation Engine (CLI & MCP)
Perfect for batch processing or letting AI do the work. The `framecraft-mcp` server exposes the app's core logic to AI agents.

#### Installation
```bash
brew install mario-hernandez/framecraft/framecraft-mcp
```

#### Automate with Claude
Connect FrameCraft to Claude Desktop to generate assets using natural language.

> "Take all screenshots in my folder and frame them with the 'Sunset' template for iPhone 15 Pro."

[👉 **Read the Easy Setup Guide**](https://mario-hernandez.github.io/framecraft/setup.html)

## 🛠️ For Contributors

### Project Structure
- `FrameCraftApp/`: The native macOS GUI (SwiftUI).
- `Sources/FrameCraftCLI/`: The command-line tool and MCP server.
- `Sources/HeroGenerator/`: Shared core logic and rendering engine.

### Building from Source
```bash
# Clone the repo
git clone https://github.com/mario-hernandez/framecraft.git

# Build the App
xcodebuild -project FrameCraftApp/FrameCraftApp.xcodeproj -scheme FrameCraftApp build

# Build the CLI
swift build -c release
```

## 📄 License

FrameCraft is open-source software licensed under the [MIT license](LICENSE).

<div align="center">
  <sub>Built with ❤️ by Mario Hernandez. Designed for the Apple ecosystem.</sub>
</div>
