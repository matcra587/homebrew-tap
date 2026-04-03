class Peerscout < Formula
  desc "Fetch live peers for Cosmos SDK chains"
  homepage "https://github.com/matcra587/peerscout"
  version "0.1.1"
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
      sha256 "97015ee53286b58936045d5d7d2fae8a627a0bb78cd82f726acd4c2c54034829"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/peerscout/releases/download/v#{version}/peerscout_#{version}_linux_amd64.tar.gz"
      sha256 "42135be93b07efcd447c487d24f026c3941d8340dcc01d5c02f640157f7a9d92"
    end
    on_arm do
      url "https://github.com/matcra587/peerscout/releases/download/v#{version}/peerscout_#{version}_linux_arm64.tar.gz"
      sha256 "8d9d90a0cf41e9837c6171c4bd1a74ce3d50c0397f769970009bcf3dcfce6df4"
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

    generate_completions_from_executable(bin/"peerscout", "--print-completion", shell_parameter_format: "--@shell=")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/peerscout version")
  end
end
