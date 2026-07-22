class Jira < Formula
  desc "Agent-first Jira CLI for developer workflows"
  homepage "https://github.com/matcra587/jira-cli"
  version "0.14.0"
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
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_darwin_arm64.tar.gz"
      sha256 "bb408ba2908e58e3509d0b9ca91e1585eb2a5d483a3ca684ca4b05f66a574a67"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_linux_amd64.tar.gz"
      sha256 "825566430f81c8b72ed38a6544ce9c71298c20fb1319c3478d49aa79a99954e1"
    end
    on_arm do
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_linux_arm64.tar.gz"
      sha256 "8e7171d7b137833fb5ea4e141d64f9dbe18f3a1122be7198d683f86e2a7a0300"
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
    assert_match "Jira CLI", shell_output("#{bin}/jira --help")
  end
end
