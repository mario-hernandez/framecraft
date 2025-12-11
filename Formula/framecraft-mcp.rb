class FramecraftMcp < Formula
  desc "MCP Server for FrameCraft - Automate App Store screenshots with Claude"
  homepage "https://github.com/mario-hernandez/framecraft"
  url "https://github.com/mario-hernandez/framecraft/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "212b5762f5a6499801e679a24da322db17836237cd6647753a3158d508a8f4cf"
  license "MIT"

  depends_on :xcode => ["15.0", :build]

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release", "--product", "framecraft-mcp"
    bin.install ".build/release/framecraft-mcp"
  end

  test do
    system "#{bin}/framecraft-mcp", "--version"
  end
end
