class GithubDocsMcp < Formula
  desc "Read-only MCP server for GitHub documentation"
  homepage "https://github.com/matcra587/github-docs-mcp"
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
      url "https://github.com/matcra587/github-docs-mcp/releases/download/v0.2.2/github-docs-mcp_0.2.2_darwin_arm64.tar.gz"
      sha256 "649689be3e07c1d7870b7a8c1d5eaf0cc6d1175293fa44f5c0b75b8810a914fd"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/github-docs-mcp/releases/download/v0.2.2/github-docs-mcp_0.2.2_linux_amd64.tar.gz"
      sha256 "7f35d7d4844452e93840866e6cdbcaa62dc480eae78cab895e05f8342817140f"
    end
    on_arm do
      url "https://github.com/matcra587/github-docs-mcp/releases/download/v0.2.2/github-docs-mcp_0.2.2_linux_arm64.tar.gz"
      sha256 "6a2ead3d8bed4971ede60e4d34ce3c3d34dc9d5d342dc5bf1f2966e031b2639c"
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
