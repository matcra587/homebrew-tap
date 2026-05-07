class SlackCli < Formula
  desc "Headless Slack CLI for agents, scripts, and CI jobs"
  homepage "https://github.com/matcra587/slack-cli"
  version "0.1.2"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  head do
    url "https://github.com/matcra587/slack-cli.git", branch: "main"
    depends_on "go" => :build
  end

  on_macos do
    on_arm do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slack-cli_#{version}_darwin_arm64.tar.gz"
      sha256 "f55fc4d09cd949986a3cd68a521696610deb6171144a3906d201f91dcf4b308a"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slack-cli_#{version}_linux_amd64.tar.gz"
      sha256 "0acb442be320a2e65390d52a81977600b78020f1d963bb4996476710fa13bb3d"
    end
    on_arm do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slack-cli_#{version}_linux_arm64.tar.gz"
      sha256 "af0d5adeca3075097dfbca22521820e3f488eb6e537141b3eeb179adf4c233a4"
    end
  end

  def install
    if build.head?
      head_version = Utils.safe_popen_read("git", "describe", "--tags", "--abbrev=0").strip.delete_prefix("v")
      commits_ahead = Utils.safe_popen_read("git", "rev-list", "v#{head_version}..HEAD", "--count").strip
      head_version = "#{head_version}-#{commits_ahead}" if commits_ahead != "0"
      ldflags = %W[
        -s -w
        -X github.com/matcra587/slack-cli/internal/version.Version=#{head_version}
        -X github.com/matcra587/slack-cli/internal/version.Commit=#{Utils.git_short_head}
        -X github.com/matcra587/slack-cli/internal/version.Branch=HEAD
        -X github.com/matcra587/slack-cli/internal/version.BuildTime=#{time.iso8601}
        -X github.com/matcra587/slack-cli/internal/version.BuildBy=homebrew
      ]
      system "go", "build", *std_go_args(ldflags: ldflags, output: bin/"slick"), "./cmd/slick"
    else
      bin.install "slick"
    end

    generate_completions_from_executable(bin/"slick", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/slick version")
  end
end
