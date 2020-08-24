{
  # Nixpkgs to use (pinned version)
  nixpkgs ? (import <nixpkgs>)
  # Allow to build for other systems
, system ? builtins.currentSystem
  # Allow to override config
, config ? {}
}:
{
  /*
  :: Map Name Path

  Set of local project packages by package name and their relative location. Example:

  ```
  {
    package1-name = ./package1-src;
    package2-name = ./package2-src;
  }
  ```
  */
    packages ? { } # :: { <package name> :: Path }

  /*
  :: [Package]

  List of packages to bring in scope while in nix shell. Example:
  ```
  pkgs: with pkgs; [
    haskellPackages.cabal-install
    haskellPackages.ghcid
    postgresql
    git
  ]
  ```

  Default is cabal and ghcid.
  */
  , shellTools ? (pkgs: with pkgs.haskellPackages; [cabal-install ghcid] )

  /*
  :: Maybe Path

  Directory with .nix haskell derivations that are automatically added to the overrides. Default is none.
  */
  , derivationsDir ? null

  /*
  :: [Overlay]

  Additional overlays where you can override system and haskell packages.

  Note: wrap with `()` import of overlay nix file either you will get `infinite recusion encountered`
  */
  , overlays ? []

  /*
  :: String

  Name of compiler field e.x. ghc883
  */
  , compiler ? "ghc883"
}:
let
  pkgs = nixpkgs { inherit system overlays; config = projectConfig; };
  lib  = pkgs.haskell.lib;
  projectConfig = {
    packageOverrides = super: let self = super.pkgs; in
    {
      haskell = super.haskell // {
        packages = super.haskell.packages // {
          "${compiler}" = super.haskell.packages."${compiler}".override {
            overrides = haskOverrides;
          };
        };
      };
    };

    allowBroken = true;
    allowUnfree = true;
  } // config;
  gitignore = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner  = "siers";
    repo   = "nix-gitignore";
    rev    = "ce0778ddd8b1f5f92d26480c21706b51b1af9166";
    sha256 = "1d7ab78i2k13lffskb23x8b5h24x7wkdmpvmria1v3wb9pcpkg2w";
  }) {};
  ignore = gitignore.gitignoreSourceAux ''
    .stack-work
    dist
    dist-newstyle
    .ghc.environment*
    '';
  haskOverrides = new: old: projectPkgs new // overridesDir new old;
  projectPkgs = new: builtins.mapAttrs (name: src: new.callCabal2nix name (ignore src) {}) packages;
  overridesDir = new: old: if derivationsDir != null then lib.packagesFromDirectory { directory = derivationsDir; } new old else {};
  outPackages = builtins.mapAttrs (name: _: pkgs.haskell.packages."${compiler}"."${name}") packages;
  shell = pkgs.haskell.packages."${compiler}".shellFor {
    nativeBuildInputs = shellTools pkgs;
    packages = _: pkgs.lib.attrValues outPackages;
  };
in {
  inherit pkgs shell;
  packages = outPackages;
}
