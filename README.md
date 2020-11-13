# haskell-nix

It is simple nix script that I reuse between my projects. See [default.nix](./default.nix) for parameters and
[templates](https://github.com/NCrashed/haskell-nix-templates) for usage.

# Fast setup

You need to create three files in your repo:
- `release.nix` where your define your project parameters.
- `shell.nix` for `nix-shell`. Contents: `(import ./release.nix).shell`
- `default.nix` for `nix-build`. Contents: `(import ./release.nix).packages`
- `pkgs.nix` optional pining of Nixpkgs version.

`release.nix`:
``` Nix
let
  nixpkgs = import ./pkgs.nix;
  project = import ((nixpkgs {}).fetchFromGitHub {
    owner = "NCrashed";
    repo = "haskell-nix";
    rev = "b3adf96fe319c59d4d8f0ddde23b75a2e452c087";
    sha256  = "0ld2bfhval31i6f23cvlz33ays6gaazhqg1r16y0aikwaciw0np7";
  }) { inherit nixpkgs; };
in project {
  packages = {
    application = ./application; # here you define mapping name -> path for your project packages
  };
}
```

`pkgs.nix`:
``` Nix
import ((import <nixpkgs> {}).fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs-channels";
  rev = "84d74ae9c9cbed73274b8e4e00be14688ffc93fe";
  sha256  = "0ww70kl08rpcsxb9xdx8m48vz41dpss4hh3vvsmswll35l158x0v";
})
```
