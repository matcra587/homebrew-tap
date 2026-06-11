class Jira < Formula
  desc "Agent-first Jira CLI for developer workflows"
  homepage "https://github.com/matcra587/jira-cli"
  version "0.6.0"
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
      sha256 "3576768e765cde52d2d64b3297989004707b8165ee412f8225a737d70c98bb83"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_linux_amd64.tar.gz"
      sha256 "aedda87a675c91b1177b64a3908e42c6418141f237ac60ce75d5238d4ac36f1b"
    end
    on_arm do
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_linux_arm64.tar.gz"
      sha256 "03a0edb6de2176595abc0a7840819c95acd4cd38ad7589a25d076ab31d3babdb"
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
