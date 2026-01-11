{ lib
, stdenv
, fetchzip
, fetchurl
, makeWrapper
}:

let
  # 公式の latest を sha256 で固定したバージョン
  version = "0.1.20260110";

  toolchainUrl =
    "https://cli.moonbitlang.com/binaries/latest/moonbit-darwin-aarch64.tar.gz";

  coreUrl =
    "https://cli.moonbitlang.com/cores/core-latest.tar.gz";

  toolchainSha256 = "sha256-aW8nfLXSHv3kIhkBuO9dkMkdetjeX603hiyqiDum7BA=";
  coreSha256      = "sha256-vxLc4KkthJEeDTDLdKxz+A0DqJ8JM6S9qH4vZkegCIc=";

  commonCurlOpts = [
    "-L"
    "-A"
    "curl/8.0.0"
  ];

  toolchain = fetchzip {
    url = toolchainUrl;
    sha256 = toolchainSha256;
    stripRoot = false;
    curlOptsList = commonCurlOpts;
  };

  coreTar = fetchurl {
    url = coreUrl;
    sha256 = coreSha256;
    curlOptsList = commonCurlOpts;
  };
in
stdenv.mkDerivation {
  pname = "moonbit-toolchain";
  inherit version;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    set -euo pipefail

    MOON_HOME="$out/share/moon"
    mkdir -p "$MOON_HOME"

    # 1) ツールチェイン（moon/moonc等）を配置
    cp -R "${toolchain}/"* "$MOON_HOME/"

    # 2) core標準ライブラリを $MOON_HOME/lib/core に展開
    #    toolchain の lib が read-only なので書き込み可能にする
    chmod -R u+w "$MOON_HOME/lib"
    tar -C "$MOON_HOME/lib" -xzf "${coreTar}"

    # 3) coreをbundle
    export PATH="$MOON_HOME/bin:$PATH"
    if [ -d "$MOON_HOME/lib/core" ] && [ -x "$MOON_HOME/bin/moon" ]; then
      (cd "$MOON_HOME/lib/core" && moon bundle --target all) || true
    fi

    # 4) wrapper：MOON_HOMEを固定して PATH に載せる
    mkdir -p "$out/bin"
    for exe in "$MOON_HOME/bin/"*; do
      if [ -f "$exe" ] && [ -x "$exe" ]; then
        name="$(basename "$exe")"
        makeWrapper "$exe" "$out/bin/$name" \
          --set-default MOON_HOME "$MOON_HOME" \
          --prefix PATH : "$MOON_HOME/bin"
      fi
    done
  '';

  meta = {
    description = "MoonBit toolchain (pinned) for macOS arm64";
    platforms = [ "aarch64-darwin" ];
  };
}
