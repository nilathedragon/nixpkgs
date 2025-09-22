{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  inherit (stdenvNoCC.hostPlatform) system;
  version = "17.3.2";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/frida/frida/releases/download/${version}/frida-core-devkit-${version}-linux-x86_64.tar.xz";
        hash = "sha256-WP9ImcB2H5hbr7z1TlDbsONLylUfX0yHwMQRaQTP4Tg=";
      };
      aarch64-linux = {
        url = "https://github.com/frida/frida/releases/download/${version}/frida-core-devkit-${version}-linux-arm64.tar.xz";
        hash = "sha256-Wd1opzaCd8lH4GgB/KnWcNvpFksfyqUd4m4CKxOzbmI=";
      };
    }
    .${system} or (throw "Unsupported system: ${system}");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "libfrida-core";
  inherit version;

  src = fetchurl {
    inherit (source) url hash;
  };
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include $out/lib
    tar -xf $src -C .
    install -Dm755 libfrida-core.a -t $out/lib
    install -Dm644 frida-core.h -t $out/include
    runHook postInstall
  '';

  meta = {
    description = "Frida core library intended for static linking into bindings";
    homepage = "https://frida.re/";
    changelog = "https://frida.re/news/";
    license = lib.licenses.wxWindowsException31;
    maintainers = with lib.maintainers; [ nilathedragon ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
