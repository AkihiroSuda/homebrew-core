class Redex < Formula
  include Language::Python::Shebang

  desc "Bytecode optimizer for Android apps"
  homepage "https://github.com/facebook/redex"
  license "MIT"
  revision 12
  head "https://github.com/facebook/redex.git", branch: "main"

  stable do
    url "https://github.com/facebook/redex/archive/v2017.10.31.tar.gz"
    sha256 "18a840e4db0fc51f79e17dfd749b2ffcce65a28e7ef9c2b3c255c5ad89f6fd6f"

    # Fix for automake 1.16.5
    patch do
      url "https://github.com/facebook/redex/commit/4696e1882cf88707bf7560a2994a4207a8b7c7a3.patch?full_index=1"
      sha256 "dccc41146688448ea2d99dd04d4d41fdaf7e174ae1888d3abb10eb2dfa6ed1da"
    end

    # Apply upstream fixes for GCC 11
    patch do
      url "https://github.com/facebook/redex/commit/70a82b873da269e7dd46611c73cfcdf7f84efa1a.patch?full_index=1"
      sha256 "44ce35ca93922f59fb4d0fd1885d24cce8a08d73b509e1fd2675557948464f1d"
    end
    patch do
      url "https://github.com/facebook/redex/commit/e81dda3f26144a9c94816c12237698ef2addf864.patch?full_index=1"
      sha256 "523ad3d7841a6716ac973b467be3ea8b6b7e332089f23e4788e1f679fd6f53f5"
    end
    patch do
      url "https://github.com/facebook/redex/commit/253b77159d6783786c8814168d1ff2b783d3a531.patch?full_index=1"
      sha256 "ed69a6230506704ca4cc7a52418b3af70a6182bd96abdb5874fab02f6b1a7c99"
    end

    # Fix compilation on High Sierra
    # Fix boost issue (https://github.com/facebook/redex/pull/564)
    # Remove for next release
    patch :DATA
  end

  bottle do
    rebuild 1
    sha256 cellar: :any,                 arm64_sonoma:   "627f8818ccdda40645a5795573c716406a92697f2eede1862faa7347019402cb"
    sha256 cellar: :any,                 arm64_ventura:  "d8ac21f6db847ac527193718f0ac57919c8256f43b72be26c3b848d78f23443e"
    sha256 cellar: :any,                 arm64_monterey: "e4c48fb028ab15462f82657c1884946fb5a73086a0cf75b6a23cb5472eea7373"
    sha256 cellar: :any,                 sonoma:         "f1e609d2c5397c316c5a1973bf6d9a3a2f0be6d566ca1265c48c60a453a0ee8a"
    sha256 cellar: :any,                 ventura:        "2d039c048c634a3cd4c8dc81e5cf7ac60b69c52e64cffd948450030225532cd6"
    sha256 cellar: :any,                 monterey:       "bbe72a752bbe3c2859308b383315439f3ae07d1f26c796126d60e1fb24d4de72"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d3fd51b3092f4dc8b59fdefcd79acf79dc5edbf25f4d245e58fb5685a216f5dc"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libevent" => :build
  depends_on "libtool" => :build
  depends_on "boost"
  depends_on "jsoncpp"
  depends_on "python-setuptools"
  depends_on "python@3.12"

  def install
    if build.stable?
      # https://github.com/facebook/redex/issues/457
      inreplace "Makefile.am", "/usr/include/jsoncpp", Formula["jsoncpp"].opt_include
      # Work around missing include. Fixed upstream but code has been refactored
      # Ref: https://github.com/facebook/redex/commit/3f4cde379da4657068a0dbe85c03df558854c31c
      ENV.append "CXXFLAGS", "-include set"
    end

    python_scripts = %w[
      apkutil
      redex.py
      tools/python/dex.py
      tools/python/dict_utils.py
      tools/python/file_extract.py
      tools/python/reach_graph.py
      tools/redex-tool/DexSqlQuery.py
      tools/redexdump-apk
    ]
    rewrite_shebang detected_python_shebang, *python_scripts

    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", *std_configure_args,
                          "--disable-silent-rules",
                          "--with-boost=#{Formula["boost"].opt_prefix}"
    system "make"
    system "make", "install"
  end

  test do
    resource "homebrew-test_apk" do
      url "https://raw.githubusercontent.com/facebook/redex/fa32d542d4074dbd485584413d69ea0c9c3cbc98/test/instr/redex-test.apk"
      sha256 "7851cf2a15230ea6ff076639c2273bc4ca4c3d81917d2e13c05edcc4d537cc04"
    end

    testpath.install resource("homebrew-test_apk")
    system bin/"redex", "--ignore-zipalign", "redex-test.apk", "-o", "redex-test-out.apk"
    assert_predicate testpath/"redex-test-out.apk", :exist?
  end
end

__END__
diff --git a/libresource/RedexResources.cpp b/libresource/RedexResources.cpp
index 525601ec..a359f49f 100644
--- a/libresource/RedexResources.cpp
+++ b/libresource/RedexResources.cpp
@@ -16,6 +16,7 @@
 #include <map>
 #include <boost/regex.hpp>
 #include <sstream>
+#include <stack>
 #include <string>
 #include <unordered_set>
 #include <vector>
diff --git a/libredex/Show.cpp b/libredex/Show.cpp
index b042070f..5e492e3f 100644
--- a/libredex/Show.cpp
+++ b/libredex/Show.cpp
@@ -9,7 +9,14 @@

 #include "Show.h"

+#include <boost/version.hpp>
+// Quoted was accepted into public components as of 1.73. The `detail`
+// header was removed in 1.74.
+#if BOOST_VERSION < 107400
 #include <boost/io/detail/quoted_manip.hpp>
+#else
+#include <boost/io/quoted.hpp>
+#endif
 #include <sstream>

 #include "ControlFlow.h"
