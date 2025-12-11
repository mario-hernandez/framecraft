import Foundation
import FrameCraftCore

// MARK: - FrameCraft MCP CLI
// Model Context Protocol server for App Store frame generation

// Check command line arguments
let args = CommandLine.arguments
if args.contains("--version") || args.contains("-v") {
    print("FrameCraft MCP v1.0.0")
    exit(0)
}

if args.contains("--help") || args.contains("-h") {
    print("""
    FrameCraft MCP Server
    v1.0.0

    Usage: framecraft-mcp [options]

    Options:
      -v, --version   Show version information
      -h, --help      Show this help message

    This tool is designed to be run by an MCP client (like Claude Desktop) via stdio.
    """)
    exit(0)
}

let server = MCPServer()

// Read from stdin line by line (JSON-RPC messages)
while let line = readLine() {
    guard !line.isEmpty else { continue }

    // Parse and handle the request
    guard let data = line.data(using: .utf8) else { continue }

    if let responseData = server.handleRequest(data),
       let responseString = String(data: responseData, encoding: .utf8) {
        // Write response to stdout
        print(responseString)
        fflush(stdout)
    }
}
