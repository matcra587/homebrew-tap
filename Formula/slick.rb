class Slick < Formula
  desc "Headless Slack CLI for agents, scripts, and CI jobs"
  homepage "https://github.com/matcra587/slack-cli"
  version "0.5.2"
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
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slick_#{version}_darwin_arm64.tar.gz"
      sha256 "5fe9463d460bc1cf2d9391c3bb3c4073e9c9b5fc48923474ac123c27d7a365fa"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slick_#{version}_linux_amd64.tar.gz"
      sha256 "6a8f43f3684c5d56dcc650354f1f9796ed506e94d0981bb0dffb9ffdc3cbd7dc"
    end
    on_arm do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slick_#{version}_linux_arm64.tar.gz"
      sha256 "bfbf34ab186c7ba93b0add788ca604274934725c86a9cac323f6a16c3d0daf8a"
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
      system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/slick"
    else
      bin.install "slick"
    end

    generate_completions_from_executable(bin/"slick", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/slick version")
  end
end
