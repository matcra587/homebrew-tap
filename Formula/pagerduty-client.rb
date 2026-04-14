class PagerdutyClient < Formula
  desc "PagerDuty CLI client and TUI dashboard"
  homepage "https://github.com/matcra587/pagerduty-client"
  version "0.13.1"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  head do
    url "https://github.com/matcra587/pagerduty-client.git", branch: "main"
    depends_on "go" => :build
  end

  on_macos do
    on_arm do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v#{version}/pagerduty-client_#{version}_darwin_arm64.tar.gz"
      sha256 "7638927d702c94a8540627360c81837f2a47fed24379c8835e5c6fe86439276d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v#{version}/pagerduty-client_#{version}_linux_amd64.tar.gz"
      sha256 "9d6b00402db59d8a7e06a3ca48812eeccef168b7e11060bf68bd38e4dc375f14"
    end
    on_arm do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v#{version}/pagerduty-client_#{version}_linux_arm64.tar.gz"
      sha256 "5de7004de0f0d443090157211502b2674e584501eaae98eda255847275a31fe1"
    end
  end

  def install
    if build.head?
      head_version = Utils.safe_popen_read("git", "describe", "--tags", "--abbrev=0").strip.delete_prefix("v")
      commits_ahead = Utils.safe_popen_read("git", "rev-list", "v#{head_version}..HEAD", "--count").strip
      head_version = "#{head_version}-#{commits_ahead}" if commits_ahead != "0"
      ldflags = %W[
        -s -w
        -X github.com/matcra587/pagerduty-client/internal/version.Version=#{head_version}
        -X github.com/matcra587/pagerduty-client/internal/version.Commit=#{Utils.git_short_head}
        -X github.com/matcra587/pagerduty-client/internal/version.Branch=HEAD
        -X github.com/matcra587/pagerduty-client/internal/version.BuildTime=#{time.iso8601}
        -X github.com/matcra587/pagerduty-client/internal/version.BuildBy=homebrew
      ]
      system "go", "build", *std_go_args(ldflags: ldflags, output: bin/"pdc"), "./cmd/pdc"
    else
      bin.install "pdc"
    end

    generate_completions_from_executable(bin/"pdc", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pdc version")
  end
end
