{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  lz4,
  libxkbcommon,
  installShellFiles,
  scdoc,
}:

rustPlatform.buildRustPackage rec {
  name = "swww";

  src = fetchFromGitHub {
    owner = "Nynxz";
    repo = "swww";
    rev = "3a6b8b30bd271b0fdeaa0ba34771e5038cec7af9";
    sha256 = "sha256-DPNYrvgyABzwdlC/iZe4hySFYpD0uPvmpDNG0BP2UVY=";
  };


  # cargoLock = {
  #   lockFile = ./Cargo.lock;
  #   outputHashes = {
  #     "bitcode-0.6.0" = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  #   };
  # };
  cargoHash = "sha256-qV+N7FteBCxmOkMZjW13jOqy4ZDLLqeZY+Ng9lM8J0I=";

  buildInputs = [
    lz4
    libxkbcommon
  ];

  doCheck = false; # Integration tests do not work in sandbox environment

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    scdoc
  ];

  postInstall = ''
    for f in doc/*.scd; do
      local page="doc/$(basename "$f" .scd)"
      scdoc < "$f" > "$page"
      installManPage "$page"
    done

    installShellCompletion --cmd swww \
      --bash completions/swww.bash \
      --fish completions/swww.fish \
      --zsh completions/_swww
  '';

  meta = {
    description = "Efficient animated wallpaper daemon for wayland, controlled at runtime";
    homepage = "https://github.com/LGFae/swww";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [
      mateodd25
      donovanglover
    ];
    platforms = lib.platforms.linux;
    mainProgram = "swww";
  };
}
