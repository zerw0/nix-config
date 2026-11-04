{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  omp = pkgs.stdenvNoCC.mkDerivation {
    pname = "oh-my-pi";
    version = "18.16.0";

    src = pkgs.fetchurl {
      url = "https://build.stencil.so/d/omp/20261102-194957-650f3a1/omp-darwin-arm64";
      sha256 = "d4a10d97488d6054d2b18198bd24f461079952c7e0fb75ba66336ca0df0cb99e";
    };

    dontUnpack = true;
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/omp"
      runHook postInstall
    '';

    meta = {
      description = "Oh My Pi terminal coding agent";
      homepage = "https://omp.sh";
      license = lib.licenses.mit;
      platforms = [ "aarch64-darwin" ];
      mainProgram = "omp";
    };
  };

  ompDefaults = (pkgs.formats.yaml { }).generate "omp-defaults.yml" {
    modelRoles.default = "openai-codex/*";
    memory.backend = "off";
  };
in
{
  options.dots.dev-tools.enable = lib.mkEnableOption "developer CLI tools (nix, git, glab, awscli, agenix)";

  config = lib.mkIf config.dots.dev-tools.enable {
    home.packages =
      (with pkgs; [
        nixd
        glab
        awscli2
        pwgen
        age
        git-lfs
        iperf3
        just
        jq
        yq-go
        lazygit
        nh
        nix-output-monitor
        inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ])
      ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") [ omp ];

    # Seed writable settings once, so /model and /settings can save later changes.
    home.activation.ompDefaults = lib.mkIf (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e "${config.home.homeDirectory}/.omp/agent/config.yml" ] && \
           [ ! -e "${config.home.homeDirectory}/.omp/agent/config.yaml" ]; then
          run install -d -m700 "${config.home.homeDirectory}/.omp/agent"
          run install -m600 ${ompDefaults} "${config.home.homeDirectory}/.omp/agent/config.yml"
        fi
      ''
    );

    home.file.".omp/agent/AGENTS.md" = lib.mkIf (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") {
      text = ''
        # Existing Codex knowledge

        Consult the existing Codex memory store as read-only background knowledge.
        Never create, modify, delete, rename, or consolidate files under ~/.codex.
        Do not access Codex credential files or databases.

        For work involving prior decisions, existing projects, or user preferences:
        1. Read ~/.codex/memories/memory_summary.md if it exists.
        2. Search ~/.codex/memories/MEMORY.md for relevant project keywords.
        3. Read only directly relevant referenced notes under rollout_summaries/ or skills/.
        Skip this lookup for simple, self-contained tasks.

        Existing memories can be stale. Verify current repository and runtime facts.
        Current user instructions and project AGENTS.md files take precedence.
        If ~/.codex/AGENTS.md exists, read and follow its applicable guidance too.
        Saved knowledge does not resume a Codex conversation or its active context.
        Do not copy memory contents into this configuration or the Nix store.
      '';
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
