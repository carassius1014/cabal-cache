{ pkgs }:

with pkgs;

let ghcVersion = "ghc962";
in mkShell {
  buildInputs = [
    cabal-install
    ghcid
    haskell.compiler."${ghcVersion}"
    hpack
    nixfmt
    stylish-haskell
    zlib
  ];
}
