# Evaluate the devshell environment
pkgs:
{ configuration
, lib ? pkgs.lib
, extraSpecialArgs ? { }
}:
let
  eval = import ./eval.nix { inherit pkgs lib extraSpecialArgs; };

  module = eval.evalModule configuration;
in
{
  inherit (module) config options;

  shell = module.config.devshell.shell;
}
