{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    codex-haskell.url = "github:herp-inc/codex?ref=haskell-tools&dir=haskell";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
        haskellTools = inputs.codex-haskell.tools.${system};
        ghcVersion = "ghc965";

        buildDeps = import ./nix/build-deps.nix { inherit pkgs; };
        devTools =
          import ./nix/dev-tools.nix { inherit ghcVersion haskellTools pkgs; };
        buildInputs = buildDeps ++ devTools;
      in {
        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
        };
      });
}
