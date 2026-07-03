class Jira < Formula
  desc "Agent-first Jira CLI for developer workflows"
  homepage "https://github.com/matcra587/jira-cli"
  version "0.7.4"
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
      sha256 "4ab9680568bb1f25b415efaf1b7b80448bd3da47203a0ee998689dbd914d3c05"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_linux_amd64.tar.gz"
      sha256 "d33b0968377352c47f48da19d04e61de026d2dd7fdaf4dd768913fb928d78949"
    end
    on_arm do
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_linux_arm64.tar.gz"
      sha256 "c87acaf3bdef14f152612b67de99a48052ff4869a3c5223a0e50b375ac2a2d5e"
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
