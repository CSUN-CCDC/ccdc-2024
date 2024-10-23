{
  inputs = {
    nixpkgs.url = "nixpkgs";
    pkgs-vagrant.url = "github:nixos/nixpkgs/336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
  };
  outputs = { nixpkgs, pkgs-vagrant, ... }:
    let

      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "i686-linux" "aarch64-darwin" "x86_64-darwin"
        ]
          (system:
            function (import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }));

    in
    {

      devShells = forAllSystems (pkgs: {
        default = import ./devshell.nix { inherit pkgs pkgs-vagrant; };
      });
      packages = forAllSystems (pkgs: {
        default = pkgs.buildEnv {
          name = "dev-shell";
          # TEST_ENV = "test environment variable";
          paths = with pkgs; [ hello ];
          postBuild = ''
              export SHELL='/bin/bash'
            '';
        };
      });


      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
