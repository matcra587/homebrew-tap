class Slick < Formula
  desc "Headless Slack CLI for agents, scripts, and CI jobs"
  homepage "https://github.com/matcra587/slack-cli"
  version "0.5.4"
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
      sha256 "2664d7ca6747a8ea1ea5c5f9ead6afd952ec78f53a93f0267ee9a48e2aa438cf"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slick_#{version}_linux_amd64.tar.gz"
      sha256 "a7b277d981b8269aa48ca5ced0fd4d15b63bf044e73f1a4f21c8d8e3466ac5fb"
    end
    on_arm do
      url "https://github.com/matcra587/slack-cli/releases/download/v#{version}/slick_#{version}_linux_arm64.tar.gz"
      sha256 "4493c460a9da5e510ca9bf2137ca4ca6b22239685b98a3a517a08a6c6139a048"
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
