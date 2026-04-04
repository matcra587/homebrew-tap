class PagerdutyClient < Formula
  desc "PagerDuty CLI client and TUI dashboard"
  homepage "https://github.com/matcra587/pagerduty-client"
  version "0.9.0"
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
      sha256 "e2f5af0b18894fda676e3246a454123cbbd6f44b7a7864e5f7d188004ef832a0"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v#{version}/pagerduty-client_#{version}_linux_amd64.tar.gz"
      sha256 "b905d04cc10b7bdfb5226144325174764960a34cfd03e6bcf7a8bd073ff1ee23"
    end
    on_arm do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v#{version}/pagerduty-client_#{version}_linux_arm64.tar.gz"
      sha256 "23b10b9180f1d048a7ca214479963af771852e5e8d3464475ec8774ed2e26163"
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

    generate_completions_from_executable(bin/"pdc", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pdc version")
  end
end
