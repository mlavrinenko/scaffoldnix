{
  description = "A tool to scaffold any project using a nix flake.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "systems";
  };

  outputs =
    inputs@{
      flake-parts,
      systems,
      ...
    }:
    let
      build = import ./src/lib/build.nix;
      modules = {
        php = ./src/modules/php.nix;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;
      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [ nixd ];
          };
        };
      flake = { inherit build modules; };
    };
}
