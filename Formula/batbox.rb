class Batbox < Formula
  desc "Terminal coding agent for local and cloud model servers"
  homepage "https://github.com/Digital-Disconnections-LTD/batbox"
  url "https://github.com/Digital-Disconnections-LTD/batbox/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "e8d277fe6e8c1c1337bde8b0c29b0641d94fc1fc317d3b360593cd02fdb29842"
  license "MIT"
  head "https://github.com/Digital-Disconnections-LTD/batbox.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/Digital-Disconnections-LTD/homebrew-batbox/releases/download/batbox-0.1.1"
    rebuild 1
    sha256               arm64_tahoe:  "c52e4cd50b17f3173a5f70d17293104f3d8b0a3835ab2d3590b48de8838c07e9"
    sha256 cellar: :any, x86_64_linux: "3af94de4a97358da41aa0823df486d5bf261e48f8ee661af73d1ace1bae1d6ec"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "nlohmann-json" => :build
  depends_on "pkgconf" => :build
  depends_on "cmark-gfm"
  depends_on "curl"
  depends_on "glib"
  depends_on "icu4c@79"
  depends_on "libuv"
  depends_on "openssl@3"
  depends_on "pcre2"
  depends_on "ripgrep"
  depends_on "vips"
  depends_on "yaml-cpp"

  on_macos do
    depends_on "gettext"
  end

  resource "ftxui" do
    url "https://github.com/ArthurSonzogni/FTXUI/archive/f921fad208912747c17d129a8ef75ec7624b6eec.tar.gz"
    sha256 "00e1426f5b13d7748af44925768cca3bc4f64aa3b02e4c82567fd85716911a5b"
  end

  resource "ada" do
    url "https://github.com/ada-url/ada/archive/refs/tags/v4.0.0.tar.gz"
    sha256 "6d6c7ef7dd2e329320d34eb2ab29ccdc879ee3935af9dfb894a6640e58dc381d"
  end

  def install
    resource("ftxui").stage buildpath/"deps/ftxui"
    resource("ada").stage buildpath/"deps/ada"

    args = %W[
      -DBUILD_TESTING=OFF
      -DBATBOX_FETCH_CMARK_GFM=OFF
      -DFETCHCONTENT_FULLY_DISCONNECTED=ON
      -DFETCHCONTENT_SOURCE_DIR_BATBOX_FTXUI_UPSTREAM=#{buildpath}/deps/ftxui
      -DBATBOX_ADA_SOURCE_DIR=#{buildpath}/deps/ada
    ]
    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args, *std_cmake_args
    system "cmake", "--build", "build", "--target", "batbox"
    system "cmake", "--install", "build", "--strip"
  end

  def caveats
    <<~EOS
      Batbox talks to a model endpoint you configure. Point it at one first:
        batbox            # opens the welcome screen; /config sets the endpoint and model
      Docs: https://github.com/Digital-Disconnections-LTD/batbox/blob/main/docs/getting-started.md

      Web search and page fetching are optional. To add them (no Docker needed):
        batbox setup web
      Check what is wired up at any time with:
        batbox doctor
    EOS
  end

  test do
    assert_match(/^batbox \d+\.\d+\.\d+$/, shell_output("#{bin}/batbox --version"))
    assert_match "Usage: batbox", shell_output("#{bin}/batbox --help")
  end
end
