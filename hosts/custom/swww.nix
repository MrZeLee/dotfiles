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
    owner = "LGFae";
    repo = "swww";
    rev = "3e2e2ba8f44469a1446138ee97d2988e22b093bf";
    sha256 = "sha256-XBwgv80YfLZ70XYVEnR0nA7Rz5jP241D5FiwrTg7tDk=";
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
