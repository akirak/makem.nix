{
  description = "Minimal flake project";

  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    twist.url = "github:akirak/emacs-twist";
    melpa = {
      url = "github:akirak/melpa/twist";
      flake = false;
    };
    gnu-elpa = {
      url = "git+https://git.savannah.gnu.org/git/emacs/elpa.git?ref=main";
      flake = false;
    };

    makem = {
      url = "github:alphapapa/makem.sh";
      flake = false;
    };

    emacs-ci = {
      url = "github:purcell/nix-emacs-ci";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    } @ inputs:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    flake-utils.lib.eachSystem systems
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import (inputs.emacs-ci + "/overlay.nix"))
            inputs.twist.overlay
          ];
        };

        makeDrvs = pkgs.callPackage ./lib.nix {
          emacs = pkgs.emacs-27-2;
          lockDir = ./lock;
          inventories = [
            {
              type = "elpa";
              path = inputs.gnu-elpa.outPath + "/elpa-packages";
            }
            {
              type = "melpa";
              path = inputs.melpa.outPath + "/recipes";
            }
          ];
          makem = inputs.makem.outPath;
        };

        defaultDrvs = makeDrvs { };
      in
      rec {
        packages = flake-utils.lib.flattenTree {
          inherit (defaultDrvs.emacsForLint.admin "lock") lock update;
          lint = defaultDrvs.wrapper;
        };
        defaultPackage = packages.lint;
      });
}
