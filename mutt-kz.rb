# A mutt fork by Karel Zak with notmuch integration and UI improvements.
require "formula"

class MuttKz < Formula
  homepage "https://kzak.redcrew.org/doku.php?id=mutt:start"
  url "ftp://redcrew.org/pub/mutt-kz/v1.5.23.1/mutt-kz-1.5.23.1.tar.xz"
  sha1 "40d80a05661d86f0a8b8b191252c8fdf7bb0db94"
  version "1.5.23.1"

  head do
    url "https://github.com/karelzak/mutt-kz.git", :using => :git
  end

  conflicts_with "mutt",
    :because => "this is a fork of mutt"

  conflicts_with 'tin',
    :because => 'both install mmdf.5 and mbox.5 man pages'

  option "with-debug", "Build with debug option enabled"
  option "with-trash-patch", "Apply trash folder patch"
  option "with-s-lang", "Build against slang instead of ncurses"

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "openssl"
  depends_on "notmuch"
  depends_on "s-lang" => :optional
  depends_on "gpgme" => :optional

  patch do
    url "ftp://ftp.openbsd.org/pub/OpenBSD/distfiles/mutt/trashfolder-1.5.22.diff0.gz"
    sha1 "c597566c26e270b99c6f57e046512a663d2f415e"
  end if build.with? "trash-patch"

  def install
    args = ["--disable-dependency-tracking",
            "--disable-warnings",
            "--prefix=#{prefix}",
            "--with-ssl=#{Formula["openssl"].opt_prefix}",
            "--enable-notmuch",
            "--with-sasl",
            "--with-gss",
            "--enable-smtp",
            # This is just a trick to keep 'make install' from trying
            # to chgrp the mutt_dotlock file (which we can't do if
            # we're running as an unprivileged user)
            "--with-homespool=.mbox"]
    args << "--with-slang" if build.with? "s-lang"
    args << "--enable-gpgme" if build.with? "gpgme"

    if build.with? "debug"
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    system "./prepare", *args
    system "make"
    system "make", "install"

  end

  test do
    system bin/"mutt", "-D"
  end
end
