class PagerdutyClient < Formula
  desc "PagerDuty CLI client and TUI dashboard"
  homepage "https://github.com/matcra587/pagerduty-client"
  version "0.7.0"
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
      sha256 "da555a0fdc31a4c41e5d766ad25ee9c815bf62dc8f187c9fa0c43ecb7c05d118"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v#{version}/pagerduty-client_#{version}_linux_amd64.tar.gz"
      sha256 "60a003df4e4173390cef568a99811d7262f0b3f5dab21178a12c0189f6cca3f3"
    end
    on_arm do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v#{version}/pagerduty-client_#{version}_linux_arm64.tar.gz"
      sha256 "e90fb90c8978a7dacb3425f2860cb929d87c6ab7ab0780033f738807f782ba73"
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
      system "go", "build", *std_go_args(ldflags: ldflags, output: bin/"pdc")
    else
      bin.install "pdc"
    end

    generate_completions_from_executable(bin/"pdc", "--print-completion", shell_parameter_format: "--@shell=")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pdc version")
  end
end
