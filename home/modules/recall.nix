{ inputs, config, ... }:

{
  # recall's module ships with its flake, so the CLI, the watcher unit and the
  # option schema live next to the code they run. Only policy stays here.
  imports = [
    inputs.recall.homeModules.default
  ];

  programs.recall = {
    enable = true;
    ollamaUrl = "http://localhost:11434";

    # Half-lives are MEASURED, not guessed: median chunk age is 388 days in
    # the sdelcore vault and 19 days in the sagent vault. A single shared
    # half-life would pin one corpus to the decay floor (the archive) while
    # leaving the other undifferentiated (the fast-turnover digests).
    collections = {
      sdelcore = {
        path = "${config.home.homeDirectory}/Obsidian/sdelcore";
        description = "Personal vault — daily notes, projects, work, and research.";
        halfLifeDays = 365;
      };

      sagent = {
        path = "${config.home.homeDirectory}/Obsidian/sagent";
        description = "Per-host, per-project coding session digests written by sagent.";
        halfLifeDays = 30;
      };
    };
  };
}
