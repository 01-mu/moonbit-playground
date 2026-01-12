{ stdenv
, lib
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "moonbit";
  version = "latest"; # 実体は sha256 で固定する

  src = fetchurl {
    # 公式Downloadページが案内している "latest" を第一候補にする
    # 併せて .cn ミラーを fallback として入れる
    urls = [
      "https://cli.moonbitlang.com/binaries/latest/moonbit-darwin-aarch64.tar.gz"
      "https://cli.moonbitlang.cn/binaries/latest/moonbit-darwin-aarch64.tar.gz"
    ];

    # まずは fakeSha256 で取得→エラーの got: を貼って固定
    sha256 = "sha256-idh2YhlKSi18w0Wx/s+LvkLgoA7n5oyPLkB/Pz2ktR8=";
  };

  unpackPhase = ''
    mkdir -p source
    tar -xzf $src -C source
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin

    MOON_PATH="$(find source -maxdepth 5 -type f -name moon | head -n 1)"
    if [ -z "$MOON_PATH" ]; then
      echo "ERROR: moon binary not found in archive"
      echo "Archive tree:"
      find source -maxdepth 3 -print
      exit 1
    fi

    cp "$MOON_PATH" $out/bin/moon
    chmod +x $out/bin/moon
    runHook postInstall
  '';

  meta = with lib; {
    description = "MoonBit CLI";
    platforms = platforms.darwin;
    mainProgram = "moon";
  };
}
