{
  description =
    "THIS IS AN AUTO-GENERATED FILE. PLEASE DON'T EDIT IT MANUALLY.";
  inputs = {
    dash = {
      flake = false;
      owner = "magnars";
      repo = "dash.el";
      type = "github";
    };
    elsa = {
      flake = false;
      owner = "emacs-elsa";
      repo = "Elsa";
      type = "github";
    };
    "f" = {
      flake = false;
      owner = "rejeep";
      repo = "f.el";
      type = "github";
    };
    package-lint = {
      flake = false;
      owner = "purcell";
      repo = "package-lint";
      type = "github";
    };
    relint = {
      flake = false;
      owner = "mattiase";
      repo = "relint";
      type = "github";
    };
    "s" = {
      flake = false;
      owner = "magnars";
      repo = "s.el";
      type = "github";
    };
    trinary = {
      flake = false;
      owner = "emacs-elsa";
      repo = "trinary-logic";
      type = "github";
    };
    xr = {
      flake = false;
      owner = "mattiase";
      repo = "xr";
      type = "github";
    };
  };
  outputs = { ... }: { };
}
