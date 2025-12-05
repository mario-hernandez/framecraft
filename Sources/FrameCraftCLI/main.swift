import Foundation
import FrameCraftCore

// MARK: - FrameCraft MCP CLI
// Model Context Protocol server for App Store frame generation

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
