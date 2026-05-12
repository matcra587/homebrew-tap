class Slick < Formula
  desc "Headless Slack CLI for agents, scripts, and CI jobs"
  homepage "https://github.com/matcra587/slack-cli"
  version "0.5.6"
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
      sha256 "cda6092110fbfc7524b23e7f0f117ad86d7f87b8e30dd37b44a5814a79f2af14"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slick_#{version}_linux_amd64.tar.gz"
      sha256 "8da43b6ec8db0d5e8af5ccb4bdda24facb0718f91c1277b1bd44e78ca8fc361b"
    end
    on_arm do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slick_#{version}_linux_arm64.tar.gz"
      sha256 "2d6de6f22d3e77d4bd38328b69460d9d34cc21c836e83064264efbba4ec381aa"
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
