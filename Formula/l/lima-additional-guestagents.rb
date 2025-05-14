class LimaAdditionalGuestagents < Formula
  desc "Additional guest agents for Lima"
  homepage "https://lima-vm.io/"
  url "https://github.com/lima-vm/lima/archive/refs/tags/v1.1.0-rc.0.tar.gz"
  sha256 "bfae3d127b62446794f3f5c33975b35958dc29d06c15b8255cc1172ea7db134e"
  license "Apache-2.0"
  head "https://github.com/lima-vm/lima.git", branch: "master"

  # Commented out because this does not recognize `brew install ./lima.rb` as the installed dependency
  ## depends_on "lima"
  depends_on "go" => :build

  def install
    if build.head?
      system "make", "additional-guestagents"
    else
      # VERSION has to be explicitly specified when building from tar.gz, as it does not contain git tags
      system "make", "additional-guestagents", "VERSION=#{version}"
    end

    share.install Dir["_output/share/*"]
  end

  test do
    info = JSON.parse shell_output("#{Formula["lima"].bin}/limactl info")
    assert_includes info["guestAgents"], "riscv64"
  end
end
