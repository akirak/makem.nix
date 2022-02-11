{ emacs
, runCommandLocal
, getopt
, makem
, makeWrapper
}:
runCommandLocal "makem-compile-${emacs.version}" {
  nativeBuildInputs = [
    makeWrapper
  ];
  propagatedBuildInputs = [
    getopt
    emacs
  ];
  passthru.exePath = "/bin/makem-compile";
} ''
  mkdir -p $out/bin
  makeWrapper ${makem}/makem.sh $out/bin/makem-compile \
    --prefix PATH : ${getopt}/bin \
    --prefix PATH : ${emacs}/bin \
    --add-flags lint-compile \
    --add-flags --install-linters
''
