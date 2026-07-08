{
  description = "Polymorphic Type Slicing - POPL 2027 submission";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };
  outputs =
    { self, nixpkgs }:
    let
      tex =
        pkgs:
        pkgs.texlive.withPackages (
          ps: with ps; [
            scheme-basic
            latex-bin
            latexmk

            acmart
            natbib
            libertine
            newtx
            # acmart checks for libertine.sty, zi4.sty (inconsolata), and
            # newtxmath.sty; if ANY is missing it silently falls back to
            # Computer Modern / Latin Modern instead of the ACM fonts. Under
            # LuaLaTeX its real font path is unicode-math + Libertinus Math
            # (+ latinmodern-math for \mathcal), so include those too.
            inconsolata
            libertinus-fonts
            lm-math
            xstring
            totpages
            environ
            hyperxmp
            ifmtarg
            comment
            draftwatermark
            ncctools
            preprint
            microtype
            xkeyval
            kvoptions

            amsmath
            amsfonts
            amscls
            mathtools

            semantic
            stmaryrd

            xcolor
            soul

            hyperref
            needspace
            setspace
            lastpage
            cleveref

            booktabs
            arydshln
            tools

            graphics
            float
            caption

            tikz-cd
            pgf
            tcolorbox
            tikzfill
            etoolbox
            pdfcol
            everyshi
            listings

            ulem
            lua-ul
            luacolor
            dutchcal
            fontspec
            lualatex-math
            unicode-math
            unicode-data
            sourcecodepro
            luacode
            luatexbase
            ctablestack

            standalone
            preview
            luatex85
            adjustbox
            collectbox
            varwidth
          ]
        );

      forEachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});

      mkDoc =
        pkgs: name:
        pkgs.stdenvNoCC.mkDerivation {
          name = "type-slicing-${name}";
          src = self;
          nativeBuildInputs = [
            pkgs.coreutils
            (tex pkgs)
          ];
          phases = [
            "unpackPhase"
            "buildPhase"
            "installPhase"
          ];
          buildPhase = ''
            export TEXMFVAR=$(mktemp -d)
            export SOURCE_DATE_EPOCH=1700000000
            export TEXINPUTS=".:$PWD/vendor/acmart:"
            export BSTINPUTS=".:$PWD/vendor/acmart:"
            latexmk -interaction=nonstopmode -halt-on-error -pdf -lualatex \
              -pretex="\pdfvariable suppressoptionalinfo 512\relax" -usepretex ${name}.tex
          '';
          installPhase = ''
            mkdir -p $out
            cp ${name}.pdf $out/ || (echo "build failed: ${name}.pdf missing" && cat ${name}.log | tail -60 && exit 1)
          '';
        };
    in
    {
      packages = forEachSystem (pkgs: {
        texenv = tex pkgs;
        main = mkDoc pkgs "main";
        supplement = mkDoc pkgs "supplement";
        default = pkgs.symlinkJoin {
          name = "type-slicing-docs";
          paths = [
            (mkDoc pkgs "main")
            (mkDoc pkgs "supplement")
          ];
        };
      });
      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = [ (tex pkgs) ];
          shellHook = ''
            export TEXINPUTS=".:$PWD/vendor/acmart:"
            export BSTINPUTS=".:$PWD/vendor/acmart:"
          '';
        };
      });
    };
}
