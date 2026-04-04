class Peerscout < Formula
  desc "Fetch live peers for Cosmos SDK chains"
  homepage "https://github.com/matcra587/peerscout"
  version "0.1.2"
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
      sha256 "b61513443b2330b526822173ecf238eb3cca45227f840b0b0aa776e68ef2c769"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matcra587/peerscout/releases/download/v#{version}/peerscout_#{version}_linux_amd64.tar.gz"
      sha256 "54bb146b773896c51d86c531756a43f59a96c7c54fbdcc0bdb8399913e3655f8"
    end
    on_arm do
      url "https://github.com/matcra587/peerscout/releases/download/v#{version}/peerscout_#{version}_linux_arm64.tar.gz"
      sha256 "47dab530c3d1997106842116398111eb0adf039a14a4d5752448026224ec0989"
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
