class GnuWhich < Formula
  desc "GNU implementation of which utility"
  # Previous homepage is dead. Have linked to the GNU Projects page for now.
  homepage "https://savannah.gnu.org/projects/which/"
  url "https://ftp.gnu.org/gnu/which/which-2.21.tar.gz"
  mirror "https://ftpmirror.gnu.org/which/which-2.21.tar.gz"
  sha256 "f4a245b94124b377d8b49646bf421f9155d36aa7614b6ebf83705d3ffc76eaad"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "651d91432ad81355ea8189f63807543d160607b5b2f87f034627b4c542d2b07a" => :mojave
    sha256 "04999e211cff8d6902f740ee08725b26b34ff1dfda82afc85d5e60243dbac927" => :high_sierra
    sha256 "27e6e35e4915cf7a6c59d3b0033962d1e643c004947dbb0eb97a41d766a8d571" => :sierra
    sha256 "e6b1179b99922a7d49b3dee829c1d31c3fa7269b000799f862361637594d34e1" => :el_capitan
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --program-prefix=g
    ]

    system "./configure", *args
    system "make", "install"

    (libexec/"gnubin").install_symlink bin/"gwhich" => "which"
    (libexec/"gnuman/man1").install_symlink man1/"gwhich.1" => "which.1"
  end

  def caveats; <<~EOS
    GNU "which" has been installed as "gwhich".
    If you need to use it as "which", you can add a "gnubin" directory
    to your PATH from your bashrc like:

        PATH="#{opt_libexec}/gnubin:$PATH"

    Additionally, you can access its man page with normal name if you add
    the "gnuman" directory to your MANPATH from your bashrc as well:

        MANPATH="#{opt_libexec}/gnuman:$MANPATH"
  EOS
  end

  test do
    system "#{bin}/gwhich", "gcc"
    system "#{opt_libexec}/gnubin/which", "gcc"
  end
end
