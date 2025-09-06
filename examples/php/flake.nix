{
  description = "My PHP project.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "systems";

    scaffoldnix.url = "path:/home/tank/projects/home/scaffoldnix";
  };

  outputs =
    inputs@{
      flake-parts,
      systems,
      scaffoldnix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;
      perSystem =
        { pkgs, ... }:
        let
          template = scaffoldnix.build {
            inherit pkgs;
            modules = [ scaffoldnix.modules.php ];
            config = {
              scaffoldnix.php = {
                enable = true;
                name = "scaffoldnix/hello-php";
                description = "Hello scaffoldnix PHP package";
              };
            };
          };
        in
        {
          packages.default = template.package;
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [ template.devPackages ];
          };
        };

      flake = { };
    };
}
