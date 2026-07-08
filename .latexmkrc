# This paper must be built with LuaLaTeX: the preamble uses luacolor + lua-ul
# (for \edited{...} review highlighting), which are LuaTeX-only packages.
$pdf_mode = 4;   # 4 = lualatex
$postscript_mode = 0;
$dvi_mode = 0;

# Guard against tools that pass `-pdf` on the command line (e.g. VS Code
# LaTeX Workshop's default recipe), which would override $pdf_mode and force
# pdfLaTeX: redefine the "pdflatex" command itself to run lualatex.
$pdflatex = 'lualatex %O %S';

# Build against the repo's vendored acmart 2.19 (vendor/acmart) ahead of
# whatever the local TeX Live ships, so the class and bst are byte-identical
# on every machine (system TeX Live, Overleaf, the Nix flake, CI).
ensure_path('TEXINPUTS', './vendor/acmart//');
ensure_path('BSTINPUTS', './vendor/acmart//');
