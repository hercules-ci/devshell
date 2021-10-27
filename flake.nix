{
  description = "devshell";

  outputs = { self }:
    let
      eachSystem = f:
        let
          op = attrs: system:
            let
              ret = f system;
              op2 = attrs: key:
                attrs // {
                  ${key} = (attrs.${key} or { }) // { ${system} = ret.${key}; };
                };
            in
            builtins.foldl' op2 attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } [
          "aarch64-linux"
          "i686-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];

      forSystem = system:
        let
          devshell = import ./. { inherit system; };
        in
        {
          defaultPackage = devshell.cli;
          legacyPackages = devshell;
          devShell = devshell.fromTOML ./devshell.toml;
        };
    in
    {
      defaultTemplate.path = ./template;
      defaultTemplate.description = "nix flake new 'github:numtide/devshell'";
      # Import this overlay into your instance of nixpkgs
      overlay = import ./overlay.nix;
      lib = {
        importTOML = import ./nix/importTOML.nix;
      };
      flakeModule = { lib, ... }:
        let inherit (lib)
          mkOption types;
        in
        {
          config = {
            perSystem = system: { config, inputs', ... }: {
              options = {
                devshell.pkgs = mkOption {
                  description = "Nixpkgs to use in devshell.";
                  type = types.lazyAttrsOf types.unspecified;
                  default = inputs'.nixpkgs.legacyPackages;
                  defaultText = lib.literalExpression or lib.literalExample ''
                    inputs'.nixpkgs.legacyPackages
                  '';
                };
                devshell.settings = mkOption {
                  description = "devshell options. See https://github.com/numtide/devshell";
                  # See https://github.com/numtide/devshell/blob/d36e4ba27668f1620a5adebf5e0c724213a0f157/modules/default.nix
                  type =
                    (import ./modules/eval.nix {
                      inherit (config.devshell) pkgs;
                      inherit lib;
                    }).type;
                  default = { };
                };
              };
              config = {
                devShell = config.devshell.settings.devshell.shell;
                checks.devshell = config.devshell.settings.devshell.shell;
              };
            };
          };
        };
    }
    //
    eachSystem forSystem;
}
