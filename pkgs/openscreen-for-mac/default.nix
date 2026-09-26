{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

let
  version = "1.12.2";

  # Upstream ships prebuilt, Developer ID-signed and notarized .dmg images for
  # macOS only; the project's own flake covers Linux. Building from source here
  # is not an option: `npm run build:mac` shells out to electron-builder and
  # downloads ffmpeg and onnxruntime at build time.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/getopenscreen/openscreen/releases/download/v${version}/Openscreen-macOS-Apple-Silicon-${version}.dmg";
      hash = "sha256-H7v5Iq14wJ7lLZd8NmaQ53kKKhE1crrDibgl+sVKF2Y=";
    };
    x86_64-darwin = {
      url = "https://github.com/getopenscreen/openscreen/releases/download/v${version}/Openscreen-macOS-Intel-${version}.dmg";
      hash = "sha256-aIZGWKXYRWV5bgJzratn/h7qI9VCwUo9b7JGYDGGpUs=";
    };
  };

  # Keep evaluation working on unsupported systems (the NUR CI evaluates the
  # whole package set on Linux); `meta.broken` keeps it out of the build set.
  source = sources.${stdenvNoCC.hostPlatform.system} or sources.aarch64-darwin;
in
stdenvNoCC.mkDerivation {
  pname = "openscreen-for-mac";
  inherit version;

  src = fetchurl source;

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R Openscreen.app "$out/Applications/"

    mkdir -p "$out/bin"
    ln -s "$out/Applications/Openscreen.app/Contents/MacOS/Openscreen" "$out/bin/openscreen"

    runHook postInstall
  '';

  # The bundle is signed and notarized; stripping or rewriting anything inside
  # it invalidates the signature, which macOS ties the screen-recording (TCC)
  # permission to.
  dontFixup = true;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Desktop screen recorder with a built-in editor (prebuilt macOS app)";
    homepage = "https://getopenscreen.com/";
    downloadPage = "https://github.com/getopenscreen/openscreen/releases";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.platforms.darwin;
    broken = !stdenvNoCC.hostPlatform.isDarwin;
    mainProgram = "openscreen";
  };
}
