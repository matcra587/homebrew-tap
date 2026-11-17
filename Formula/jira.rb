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
      url "https://github.com/matcra587/jira-cli/releases/download/v0.16.1/jira_0.16.1_darwin_arm64.tar.gz"
      sha256 "ef351c1bd63293e954384a4f2f891b6ccd2b692ecd89e73ea105bc957a88ad6c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/jira-cli/releases/download/v0.16.1/jira_0.16.1_linux_amd64.tar.gz"
      sha256 "4973aa6369fffae6340c99e47a1c3d441319a825e0aa30ccb390d49cf3857e37"
    end
    on_arm do
      url "https://github.com/matcra587/jira-cli/releases/download/v0.16.1/jira_0.16.1_linux_arm64.tar.gz"
      sha256 "cf9401e8d98cecedbfaaa440466e92e9435c33c2d25257f6e5dc36c05ca34e7d"
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
