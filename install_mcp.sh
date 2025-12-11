#!/bin/bash

# FrameCraft MCP Installer
# Builds the CLI tool and provides configuration for Claude Desktop.

set -e

echo "🚀 Installing FrameCraft MCP Server..."

# 1. Build release binary
echo "📦 Building project (Release mode)..."
swift build -c release --product framecraft-mcp

# 2. Locate binary
BINARY_PATH="$(swift build -c release --product framecraft-mcp --show-bin-path)/framecraft-mcp"

if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ Error: Build failed. Binary not found."
    exit 1
fi

echo "✅ Build successful!"
echo ""
echo "👉 To use with Claude Desktop, add this to your config:"
echo ""
echo "File: ~/Library/Application Support/Claude/claude_desktop_config.json"
echo "----------------------------------------"
echo "{"
echo "  \"mcpServers\": {"
echo "    \"framecraft\": {"
echo "      \"command\": \"$BINARY_PATH\","
echo "      \"args\": []"
echo "    }"
echo "  }"
echo "}"
echo "----------------------------------------"
echo ""
echo "💡 Tip: You can run this script again if you move the project."
