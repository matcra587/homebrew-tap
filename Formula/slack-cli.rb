class SlackCli < Formula
  desc "Headless Slack CLI for agents, scripts, and CI jobs"
  homepage "https://github.com/matcra587/slack-cli"
  version "0.3.0"
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
      sha256 "bc9d4f690d32c152641f12583419221926708fc9c4071a56662d441d272fb76e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slack-cli_#{version}_linux_amd64.tar.gz"
      sha256 "df852c8d31abb7fbde732384cd45595efae576623268b3b019c5101266829b5f"
    end
    on_arm do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slack-cli_#{version}_linux_arm64.tar.gz"
      sha256 "fd07b1db433689b4f535936f1b91538f5e77e30686f408c22c095e7d63806b97"
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
