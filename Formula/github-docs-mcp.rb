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
      url "https://github.com/matcra587/github-docs-mcp/releases/download/v0.2.1/github-docs-mcp_0.2.1_darwin_arm64.tar.gz"
      sha256 "36ecd28ee7b09695fdac720550f2f3ad931cd83a5e483da1e35b6fa5ff37cafd"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/github-docs-mcp/releases/download/v0.2.1/github-docs-mcp_0.2.1_linux_amd64.tar.gz"
      sha256 "0c3690109cc387a5a70768467c477b35777ec694deda943c44d60d553979f76d"
    end
    on_arm do
      url "https://github.com/matcra587/github-docs-mcp/releases/download/v0.2.1/github-docs-mcp_0.2.1_linux_arm64.tar.gz"
      sha256 "81f23d98fba433e81c1a21040407e9bfa95c6c9407c0d5c5be9e04e98810ea8f"
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
