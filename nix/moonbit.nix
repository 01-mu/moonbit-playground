{ lib
, stdenv
, fetchzip
, fetchurl
, makeWrapper
}:

let
  # 公式の latest を利用する
  version = "latest";

  toolchainUrl =
    "https://cli.moonbitlang.com/binaries/latest/moonbit-darwin-aarch64.tar.gz";

  coreUrl =
    "https://cli.moonbitlang.com/cores/core-latest.tar.gz";

  toolchainSha256 = "sha256-idh2YhlKSi18w0Wx/s+LvkLgoA7n5oyPLkB/Pz2ktR8=";
  coreSha256      = "sha256-vxLc4KkthJEeDTDLdKxz+A0DqJ8JM6S9qH4vZkegCIc=";

  commonCurlOpts = [
    "-L"
    "-A" "curl/8.0.0"
  ];

  toolchain = fetchzip {
    url = toolchainUrl;
    sha256 = toolchainSha256;
    stripRoot = false;
    curlOpts = commonCurlOpts;
  };

  coreTar = fetchurl {
    url = coreUrl;
    sha256 = coreSha256;
    curlOpts = commonCurlOpts;
  };
in
stdenv.mkDerivation {
  pname = "moonbit-toolchain";
  inherit version;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    set -euo pipefail

    MOON_HOME="$out/share/moon"
    mkdir -p "$MOON_HOME"

    # 1) ツールチェイン（moon/moonc等）を配置
    cp -R "${toolchain}/"* "$MOON_HOME/"

    # 2) core標準ライブラリを $MOON_HOME/lib/core に展開
    mkdir -p "$MOON_HOME/lib"
    tar -xzf "${coreTar}" -C "$MOON_HOME/lib"

    # 3) coreをbundle:contentReference[oaicite:1]{index=1}
    export PATH="$MOON_HOME/bin:$PATH"
    if [ -d "$MOON_HOME/lib/core" ] && [ -x "$MOON_HOME/bin/moon" ]; then
      (cd "$MOON_HOME/lib/core" && moon bundle --target all) || true
    fi

    # 4) wrapper：MOON_HOMEを固定して PATH に載せる
    mkdir -p "$out/bin"
    for exe in "$MOON_HOME/bin/"*; do
      name="$(basename "$exe")"
      makeWrapper "$exe" "$out/bin/$name" \
        --set-default MOON_HOME "$MOON_HOME" \
        --prefix PATH : "$MOON_HOME/bin"
    done
  '';

  meta = {
    description = "MoonBit toolchain (pinned) for macOS arm64";
    platforms = [ "aarch64-darwin" ];
  };
}
