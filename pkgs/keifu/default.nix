{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  openssl,
  makeRustPlatform,
  rust-bin,
  darwin,
  libiconv,
}:

let
  rustNightly = rust-bin.nightly.latest.default;
  rustPlatform = makeRustPlatform {
    cargo = rustNightly;
    rustc = rustNightly;
  };
in
rustPlatform.buildRustPackage {
  pname = "keifu";
  version = "unstable-2025-05-16";

  src = fetchFromGitHub {
    owner = "trasta298";
    repo = "keifu";
    rev = "23aa7af3795059beba429119670079d9c6a8f6f7";
    hash = "sha256-yk7ze4X9V0Y2UbtuJ6H0GK1uUemXi/nvMtd8QOvbzaI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-g/tMmrw+CHbMNDX+bbqT+1DbdsXl5UX394GKhie9m/0=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
    libiconv
  ];

  doCheck = false;

  meta = {
    description = "A terminal UI tool for visualizing Git commit graphs with colored branch genealogy";
    homepage = "https://github.com/trasta298/keifu";
    license = lib.licenses.mit;
    mainProgram = "keifu";
  };
}
