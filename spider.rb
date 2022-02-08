class Spider < Formula
  desc "small dart library to generate Assets dart code from assets folder."
  homepage "https://github.com/BirjuVachhani/spider"
  url "https://github.com/BirjuVachhani/spider/archive/2.2.0.tar.gz"
  sha256 "ba4a0ceea07d601dc54e2f436ba8b97833c10d5e6584c6d5d35c7952887bc456"
  license "Apache-2.0"
  
  bottle :unneeded
  
  depends_on "dart-lang/dart/dart" => :build
  
  def install
    system "pub", "get"
    system "dart2native", "bin/main.dart", "-o", "spider"
    bin.install "spider"
  end
  
  test do
    system "#{bin}/spider", "--version"
    system "touch", "pubspec.yaml"
    system "#{bin}/spider", "create"
    raise 'test failed' unless File.exists? 'spider.yaml'
  end
end
