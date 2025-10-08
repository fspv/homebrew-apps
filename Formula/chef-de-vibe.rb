class ChefDeVibe < Formula
  desc "Chef de Vibe - A Rust application with embedded React frontend"
  homepage "https://github.com/fspv/chef-de-vibe"
  license "MIT"
  
  # Note: Version and URLs will be automatically updated by GitHub Actions
  # when new releases are published in the chef-de-vibe repository
  version "0.2.6"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/fspv/chef-de-vibe/releases/download/v0.2.6/chef-de-vibe-x86_64-apple-darwin"
      sha256 "840cb77aed62fa207951888b06b45c722293863287a89cc8b5c458bb694ea04e"
    else
      url "https://github.com/fspv/chef-de-vibe/releases/download/v0.2.6/chef-de-vibe-aarch64-apple-darwin"
      sha256 "ab65886cddafc759b9435c4eef5b6bef6747f19e3447182265f5079234118720"
    end
  end

  on_linux do
    url "https://github.com/fspv/chef-de-vibe/releases/download/v0.2.6/chef-de-vibe-x86_64-unknown-linux-musl"
    sha256 "ceaf92e6f628c3faf81f82da6ad9c743fa80a8354a2b8d9f5f7308c1abd1f73a"
  end

  head do
    url "https://github.com/fspv/chef-de-vibe.git", branch: "master"
    
    depends_on "rust" => :build
    depends_on "node" => :build
    depends_on "pkg-config" => :build
    depends_on "openssl@3"
  end

  def install
    if build.head?
      # Build from source for head installs
      cd "frontend" do
        system "npm", "ci", "--legacy-peer-deps"
        system "npm", "run", "build"
      end
      system "cargo", "install", "--locked", "--root", prefix, "--path", "."
    else
      # Install pre-built binary
      bin.install Dir["chef-de-vibe*"].first => "chef-de-vibe"
    end
    
    # Create convenient alias
    bin.install_symlink bin/"chef-de-vibe" => "chef_de_vibe"
  end

  test do
    # Create required directories
    (testpath/".claude/projects").mkpath
    
    # Start the server in the background
    port = free_port
    pid = fork do
      ENV["HOME"] = testpath.to_s
      ENV["CLAUDE_BINARY_PATH"] = "/bin/sleep"
      ENV["HTTP_LISTEN_ADDRESS"] = "0.0.0.0:#{port}"
      exec "#{bin}/chef-de-vibe"
    end
    sleep 5

    # Test that the server is running
    assert_match "200", shell_output("curl -I -s -o /dev/null -w '%{http_code}' http://localhost:#{port}")
  ensure
    Process.kill("TERM", pid) if pid
    Process.wait(pid) if pid
  end

  def free_port
    require "socket"
    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]
    server.close
    port
  end
end