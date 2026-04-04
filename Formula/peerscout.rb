class Peerscout < Formula
  desc "Fetch live peers for Cosmos SDK chains"
  homepage "https://github.com/matcra587/peerscout"
  version "0.3.0"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  head do
    url "https://github.com/matcra587/peerscout.git", branch: "main"
    depends_on "go" => :build
  end

  on_macos do
    on_arm do
      url "https://github.com/matcra587/peerscout/releases/download/v#{version}/peerscout_#{version}_darwin_arm64.tar.gz"
      sha256 "e8efe8eade580f8f79646677629cc6fb570c9846046a4720ee435dc92023b3fc"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/peerscout/releases/download/v#{version}/peerscout_#{version}_linux_amd64.tar.gz"
      sha256 "4787ac99665318959d2f9108085a05703ccca5a6498e7e21d9e88880f0d82d93"
    end
    on_arm do
      url "https://github.com/matcra587/peerscout/releases/download/v#{version}/peerscout_#{version}_linux_arm64.tar.gz"
      sha256 "ebf76f9866da06fa67318d992c781c7fed446a5ff1a98c9ef58e361427e9111a"
    end
  end

  def install
    if build.head?
      head_version = Utils.safe_popen_read("git", "describe", "--tags", "--abbrev=0").strip.delete_prefix("v")
      commits_ahead = Utils.safe_popen_read("git", "rev-list", "v#{head_version}..HEAD", "--count").strip
      head_version = "#{head_version}-#{commits_ahead}" if commits_ahead != "0"
      ldflags = %W[
        -s -w
        -X github.com/matcra587/peerscout/internal/version.Version=#{head_version}
        -X github.com/matcra587/peerscout/internal/version.Commit=#{Utils.git_short_head}
        -X github.com/matcra587/peerscout/internal/version.Branch=HEAD
        -X github.com/matcra587/peerscout/internal/version.BuildTime=#{time.iso8601}
        -X github.com/matcra587/peerscout/internal/version.BuildBy=homebrew
      ]
      system "go", "build", *std_go_args(ldflags: ldflags)
    else
      bin.install "peerscout"
    end

    generate_completions_from_executable(bin/"peerscout", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/peerscout version")
  end
end
