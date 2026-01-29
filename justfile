# vim: set ft=make :
set quiet
set shell := ["bash", "-euo", "pipefail", "-c"]

public_inputs := "agenix claude-code determinate disko flake-parts home-manager home-manager-unstable nix-darwin nix-index-database nixpkgs nixpkgs-unstable nixvim nixvim-unstable treefmt-nix"

default:
    @just --list

# Update public inputs by default; pass names to select inputs.
update *inputs:
    nix flake update {{if inputs == "" { public_inputs } else { inputs }}}
    just format
    just preflight-lambda

format:
    nix fmt

check:
    nix flake check --no-build --all-systems --no-write-lock-file

build-lambda:
    nix build --no-link .#darwinConfigurations.lambda.config.system.build.toplevel

preflight-lambda: check build-lambda

diff-lambda:
    #!/usr/bin/env bash
    set -euo pipefail
    next="$(nix build --no-link --print-out-paths .#darwinConfigurations.lambda.config.system.build.toplevel)"
    nix store diff-closures /run/current-system "$next"

rollback-lambda:
    sudo darwin-rebuild --rollback

# Connection addresses, users and ports belong in ~/.ssh/config.
# Override with: just --set local-build "alias ..." deploy alias
local-build := ""

deploy host: (_deploy host "switch")

boot host: (_deploy host "boot")

dry-run host: (_deploy host "switch --dry")

[private]
_deploy host sub:
    #!/usr/bin/env bash
    set -euo pipefail
    darwin_hosts="$(nix eval --raw .#darwinConfigurations --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)')"
    if grep -Fxq '{{host}}' <<< "$darwin_hosts"; then
        if [[ '{{sub}}' == boot ]]; then
            echo "boot is only supported for NixOS hosts" >&2
            exit 1
        fi
        nh darwin {{sub}} -H '{{host}}' .
    else
        build=(--build-host '{{host}}')
        case " {{local-build}} " in *" {{host}} "*) build=();; esac
        nh os {{sub}} -H '{{host}}' --target-host '{{host}}' "${build[@]}" .
    fi

# Run before the first deployment with persistent Headplane state.
prepare-headplane-state host:
    ssh '{{host}}' 'sudo -n bash -s' < modules/homelab/services/headplane/migrate-state.sh

clean:
    nh clean all --keep 5 --keep-since 7d
