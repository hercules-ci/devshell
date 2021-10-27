# A type to evaluate the devshell environment
{ lib, pkgs, extraSpecialArgs ? { } }:
let
  devenvModules = import ./modules.nix {
    inherit pkgs lib;
  };

  specialArgs = {
    modulesPath = builtins.toString ./.;
    extraModulesPath = builtins.toString ../extra;
  } // extraSpecialArgs;

in
{
  type = lib.types.submoduleWith {
    modules = devenvModules;
    inherit specialArgs;
  };
  # Eventually replace by type.evalModules from https://github.com/NixOS/nixpkgs/pull/143133
  evalModule = configuration: lib.evalModules {
    modules = [ configuration ] ++ devenvModules;
    inherit specialArgs;
  };
}
