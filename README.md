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
    rev = "0c1c27a22daa78d359d7704448e4c6e2512cde5d";
    sha256  = "1vnbi1g6yswq5vb1fqjmh2mdnzynka2v17rnyh9j170xnza3crg2";
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
  rev = "0f5ce2fac0c726036ca69a5524c59a49e2973dd4";
  sha256  = "0nkk492aa7pr0d30vv1aw192wc16wpa1j02925pldc09s9m9i0r3";
})
```
