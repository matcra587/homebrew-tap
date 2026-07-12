class Jira < Formula
  desc "Agent-first Jira CLI for developer workflows"
  homepage "https://github.com/matcra587/jira-cli"
  version "0.10.11"
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
      sha256 "99fd53551bb1f311894def52cd7ca7ecc41290d420436206c4646e15b880130e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_linux_amd64.tar.gz"
      sha256 "83d1d5998ed0b4e3d6f4500fcab46fc9e7cfcb10be293e207c49e5c7103c6e35"
    end
    on_arm do
      url "https://github.com/matcra587/jira-cli/releases/download/v#{version}/jira_#{version}_linux_arm64.tar.gz"
      sha256 "2c29a4e51ad09da328ae2a200aac5949ea7828460221f4505581fef939880d77"
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
