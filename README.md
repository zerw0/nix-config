# Lambda Nix Setup (macOS)

This repository contains a nix-darwin flake for configuring a macOS system. Below are the minimal commands required to install Nix, clone the repository, apply the configuration, update it, or roll back changes.

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

```bash
nix --version
```

```bash
git clone https://github.com/zerw0/nix-config.git
cd nix-config
```

```bash
sudo darwin-rebuild switch --flake .#lambda
```

This setups Nix, home-manager, installs all of my programs and sets them up.
