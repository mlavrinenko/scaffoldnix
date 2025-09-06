{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.scaffoldnix.php;
in
{
  options.scaffoldnix = {
    outputs = {
      files = lib.mkOption {
        type = lib.types.attrsOf lib.types.package;
        default = { };
        description = "Generated files to include in the output";
      };

      devPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Development packages to include in the shell";
      };
    };

    php = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to generate basic files for PHP project.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        description = "name in composer.json";
      };

      description = lib.mkOption {
        type = lib.types.str;
        description = "description in composer.json";
      };

      require = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "PHP dependencies to require";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    scaffoldnix.outputs.devPackages = [ pkgs.php81Packages.composer ];
    scaffoldnix.outputs.files."composer.json" = pkgs.writeTextFile {
      name = "composer.json";
      text = builtins.toJSON {
        inherit (cfg) name description;
        require = cfg.require // {
          "php" = ">=8.1"; # TODO make it configurable.
        };
        autoload = {
          "psr-4" = {
            "App" = "src/"; # TODO make it configurable.
          };
        };
      };
    };
  };
}
