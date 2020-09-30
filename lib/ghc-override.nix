/*
  Helper that allows to define haskell overlays for specific compiler as:
  self: super: ghc-override "ghc8102" (self: super: {
    ... here gores overrides
    }) super
*/
compiler:
overrides:
super: {
  haskell = super.haskell // {
    packages = super.haskell.packages // {
      "${compiler}" = super.haskell.packages."${compiler}".extend overrides;
    };
  };
}
