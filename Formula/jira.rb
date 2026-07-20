class Jira < Formula
  desc "Agent-first Jira CLI for developer workflows"
  homepage "https://github.com/matcra587/jira-cli"
  version "0.12.2"
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
      sha256 "f0094e897b5ae8c2036366f3fc88212dcabc14265308b9b2385a996aa4c9fafc"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_linux_amd64.tar.gz"
      sha256 "b81411e9a2b2100ec38366c57f2a9c0104ffe07711ab9940516fdf59868bf757"
    end
    on_arm do
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_linux_arm64.tar.gz"
      sha256 "6d517aac8996a4eb40c4e7348b4ed76b8f53936648566b4643638ccd2f026502"
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
