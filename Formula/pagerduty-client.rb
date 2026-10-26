class PagerdutyClient < Formula
  desc "PagerDuty API client and CLI"
  homepage "https://github.com/matcra587/pagerduty-client"
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
      url "https://github.com/matcra587/pagerduty-client/releases/download/v0.13.6/pagerduty-client_0.13.6_darwin_arm64.tar.gz"
      sha256 "14e02e20ab8024cdc7491cb3eb5e29c3d885666ded5b3811431f4eaafc249635"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v0.13.6/pagerduty-client_0.13.6_linux_amd64.tar.gz"
      sha256 "de068876b49c749ed36c8d7bc0cea44108a55f5894b690f5b01c1c0ca9e748c2"
    end
    on_arm do
      url "https://github.com/matcra587/pagerduty-client/releases/download/v0.13.6/pagerduty-client_0.13.6_linux_arm64.tar.gz"
      sha256 "7084349876af4b24f7e88c5674d4fdf8fac97b78b85dfd588997ac92e5661511"
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
