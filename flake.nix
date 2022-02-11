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
      inherit (nixpkgs) lib;

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

        makeDrvs = pkgs.callPackage ./lint.nix {
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
        lint = lib.makeOverridable (args: (makeDrvs args).wrapper) { };

        byteCompileDrvs = lib.pipe pkgs.emacs-ci-versions [
          (map (name: {
            name = "compile-${name}";
            value = pkgs.callPackage ./compile.nix {
              emacs = pkgs.${name};
              makem = inputs.makem.outPath;
            };
          }))
          builtins.listToAttrs
        ];
      in
      rec {
        packages = flake-utils.lib.flattenTree ({
          inherit (defaultDrvs.emacsForLint.admin "lock") lock update;
          inherit lint;
          lint-basic = lint.override {
            doCheckdoc = true;
            doElsa = false;
            doPackageLint = true;
            doCheckDeclare = true;
            doIndentLint = false;
            doRelint = false;
          };
        } // byteCompileDrvs);
        defaultPackage = packages.lint;
        inherit (pkgs) emacs-ci-versions;
      });
}
