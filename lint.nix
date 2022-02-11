{ lib
, getopt
, bash
, makem
, writeShellScriptBin
, emacsTwist
, emacs
, lockDir
, inventories
}:
{ doCheckdoc ? true
, doElsa ? true
, doPackageLint ? true
, doCheckDeclare ? true
, doIndentLint ? true
, doRelint ? true
}:
let
  lintPackages =
    lib.optional doRelint "relint"
    ++ lib.optional doPackageLint "package-lint" # melpa
    ++ lib.optional doElsa "elsa"; # melpa

  makemRules =
    lib.optional doCheckdoc "lint-checkdoc"
    ++ lib.optional doCheckDeclare "lint-declare"
    ++ lib.optional doElsa "lint-elsa"
    ++ lib.optional doIndentLint "lint-indent"
    ++ lib.optional doPackageLint "lint-package"
    ++ lib.optional doRelint "lint-regexps";

  emacsForLint = (emacsTwist {
    inherit inventories;
    inherit lockDir;
    initFiles = [ ];
    extraPackages = lintPackages;
  }).overrideScope' (_self: super: {
    elispPackages = super.elispPackages.overrideScope' (eself: esuper:
      builtins.mapAttrs (_ename: epkg: epkg.overrideAttrs (_: {
        dontByteCompile = true;
      })) esuper
    );
  });

  wrapper = writeShellScriptBin "lint" ''
    set -euo pipefail

    makem_args=()
    if [[ $# -gt 0 ]]
    then
      for file
      do
        makem_args+=(-f "$file")
      done
    else
      for el in *.el
      do
        if [[ "$el" = *-test.el ]] \
           || [[ "$el" = *-tests.el ]] \
           || [[ "$el" = test.el ]] \
           || [[ "$el" = tests.el ]] \
           || [[ "$el" = .dir-locals.el ]]
        then
          continue
        fi
        makem_args+=(-f "$el")
      done
    fi

    # /usr/bin/env is unavailable in the sandboxed environment, so run
    # makem via a provided bash
    #
    # Also, makem requires getopt.
    PATH="${getopt}/bin:$PATH" ${bash}/bin/bash \
      ${makem}/makem.sh -E "${emacsForLint}/bin/emacs" \
      --no-compile ''${makem_args[@]} ${lib.escapeShellArgs makemRules}
  '';
in {
  inherit emacsForLint wrapper;
}
