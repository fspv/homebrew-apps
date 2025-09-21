class ChefDeVibe < Formula
  desc "Chef de Vibe - A Rust application with embedded React frontend"
  homepage "https://github.com/fspv/chef-de-vibe"
  license "MIT"
  
  # Note: Version and URLs will be automatically updated by GitHub Actions
  # when new releases are published in the chef-de-vibe repository
  version "pre-91f9454"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/fspv/chef-de-vibe/releases/download/pre-91f9454/chef-de-vibe-x86_64-apple-darwin"
      sha256 "c953ea85a803f66f3db9a64b44d86d036d9f2bce8376b49a11f6923daee476f5"
    else
      url "https://github.com/fspv/chef-de-vibe/releases/download/pre-91f9454/chef-de-vibe-aarch64-apple-darwin"
      sha256 "e73d6f58f7eb2200dd725139e43ec20b3fbf08c976a823178b9a09d0aad4aaed"
    end
  end

  on_linux do
    url "https://github.com/fspv/chef-de-vibe/releases/download/pre-91f9454/chef-de-vibe-x86_64-unknown-linux-gnu"
    sha256 "aff512d57eb0ea0cd7fd8bfab06f62a588eef9e7159e33147207ba7a5e525def"
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