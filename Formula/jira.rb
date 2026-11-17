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
      url "https://github.com/matcra587/jira-cli/releases/download/v0.16.2/jira_0.16.2_darwin_arm64.tar.gz"
      sha256 "3b53b4861a137c4d8d9e7c4c0848f53e24695a873db54288cc20d9da21b255cd"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/jira-cli/releases/download/v0.16.2/jira_0.16.2_linux_amd64.tar.gz"
      sha256 "b9322b2d89f0bd43bc99956de6e0b18eb142114c2981d3efc776283bc31e40c9"
    end
    on_arm do
      url "https://github.com/matcra587/jira-cli/releases/download/v0.16.2/jira_0.16.2_linux_arm64.tar.gz"
      sha256 "8bf83f87af4246fb2e410eb1bde2849c6d08a8844d1120e390ecd33e6d722b25"
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
