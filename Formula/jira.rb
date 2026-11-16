class Jira < Formula
  desc "Agent-first Jira CLI for developer workflows"
  homepage "https://github.com/matcra587/jira-cli"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  head do
    url "https://github.com/matcra587/jira-cli.git", branch: "main"
    depends_on "go" => :build
  end

  on_macos do
    on_arm do
      url "https://github.com/matcra587/jira-cli/releases/download/v0.16.0/jira_0.16.0_darwin_arm64.tar.gz"
      sha256 "701acc33ab4aea1a5142478d8aff01d2590b467fef06a4288e1269b623055b6b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/jira-cli/releases/download/v0.16.0/jira_0.16.0_linux_amd64.tar.gz"
      sha256 "102e8370fbd77c4309275418e78b1c04722a07d20c1546b32d8e9a6ba735fd1e"
    end
    on_arm do
      url "https://github.com/matcra587/jira-cli/releases/download/v0.16.0/jira_0.16.0_linux_arm64.tar.gz"
      sha256 "893d0021a04773072eb219ae1800fa1bba76b66fd5d7fcccee9b6a5979a7bcce"
    end
  end

  def install
    if build.head?
      head_version = Utils.safe_popen_read("git", "describe", "--tags", "--abbrev=0").strip.delete_prefix("v")
      commits_ahead = Utils.safe_popen_read("git", "rev-list", "v#{head_version}..HEAD", "--count").strip
      head_version = "#{head_version}-#{commits_ahead}" if commits_ahead != "0"
      ldflags = %W[
        -s -w
        -X github.com/matcra587/jira-cli/internal/version.Version=#{head_version}
        -X github.com/matcra587/jira-cli/internal/version.Commit=#{Utils.git_short_head}
        -X github.com/matcra587/jira-cli/internal/version.Branch=HEAD
        -X github.com/matcra587/jira-cli/internal/version.BuildTime=#{time.iso8601}
        -X github.com/matcra587/jira-cli/internal/version.BuildBy=homebrew
      ]
      system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/jira"
    else
      bin.install "jira"
    end

    generate_completions_from_executable(bin/"jira", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jira version")
  end
end
