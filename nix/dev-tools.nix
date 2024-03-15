{ pkgs, haskellTools, ghcVersion }:

with pkgs; [
  cabal-install
  haskellTools.stack-wrapped
  haskellTools.stack2cabal
  haskell.compiler.${ghcVersion}
  nixfmt
]
