{...}: let
  scripts = ./../scripts;
in {
  # Symlink every file in home/scripts/ onto PATH at ~/.local/bin. Everything in
  # that directory MUST be a real executable helper (each has a shebang + a
  # one-line purpose comment) — non-executables would land on PATH too.
  home.file = {
    ".local/bin" = {
      recursive = true;
      source = "${scripts}";
    };
  };
}
