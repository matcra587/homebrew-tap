class PagerdutyClient < Formula
  desc "PagerDuty CLI client and TUI dashboard"
  homepage "https://github.com/matcra587/pagerduty-client"
  version "0.12.1"
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
      sha256 "02ebab16f194b739f3b76f4b037265aff7c61598845e708a8c6095fabc2d8121"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v#{version}/pagerduty-client_#{version}_linux_amd64.tar.gz"
      sha256 "2c3c7333f0943638428d50868ac1266bae01418cd04a36f0e22246abb39b9050"
    end
    on_arm do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v#{version}/pagerduty-client_#{version}_linux_arm64.tar.gz"
      sha256 "263ff9db9a38a4c578e8142ddbda388c88cbbd46f48300e99825ee865de459ae"
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
