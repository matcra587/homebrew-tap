class GithubDocsMcp < Formula
  desc "Read-only MCP server for GitHub documentation"
  homepage "https://github.com/matcra587/github-docs-mcp"
  version "0.2.0"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  head do
    url "https://github.com/matcra587/github-docs-mcp.git", branch: "main"
    depends_on "go" => :build
  end

  on_macos do
    on_arm do
      url "https://github.com/matcra587/github-docs-mcp/releases/download/v#{version}/github-docs-mcp_#{version}_darwin_arm64.tar.gz"
      sha256 "ec8aada31c9b6ce8aed59c116b2085a19d434221e31e68c21d670a6d9922a8ba"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/github-docs-mcp/releases/download/v#{version}/github-docs-mcp_#{version}_linux_amd64.tar.gz"
      sha256 "40e9f1de9496af2ed38c7822c44a0d4fd4b466116a0cef95677332b13f1c057a"
    end
    on_arm do
      url "https://github.com/matcra587/github-docs-mcp/releases/download/v#{version}/github-docs-mcp_#{version}_linux_arm64.tar.gz"
      sha256 "af142120f72dcd2d5df2dbc1628a0af9c9ce2d4ec2156ae22b1d1fe4f6d6ecfe"
    end
  end

  def install
    if build.head?
      system "go", "build", *std_go_args, "./cmd/github-docs-mcp"
    else
      bin.install "github-docs-mcp"
    end
  end

  test do
    assert_match "github-docs-mcp", shell_output("#{bin}/github-docs-mcp -version")
  end
end
