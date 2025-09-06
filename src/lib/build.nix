{
  pkgs,
  config,
  modules ? [ ],
  specialArgs ? { },
}:
let
  lib = pkgs.lib;

  # Evaluate all modules with NixOS module system
  moduleResult = lib.evalModules {
    modules = modules ++ [
      (
        { ... }:
        {
          inherit config;
        }
      )
    ];
    specialArgs = specialArgs // {
      inherit pkgs lib;
    };
  };

  # Build a derivation that lays out all generated files
  derivation = pkgs.stdenv.mkDerivation {
    name = "scaffoldnix-project";
    phases = [ "installPhase" ];
    installPhase =
      let
        files = lib.attrsets.mapAttrsToList (name: file: ''
          mkdir -p "$(dirname "$out/${name}")"
          cp ${file} "$out/${name}"
        '') moduleResult.config.scaffoldnix.outputs.files;
      in
      ''
        mkdir -p $out
        ${lib.concatStringsSep "\n" files}
      '';
  };
in
{
  package = derivation;
  devPackages = moduleResult.config.scaffoldnix.outputs.devPackages or [ ];
}
