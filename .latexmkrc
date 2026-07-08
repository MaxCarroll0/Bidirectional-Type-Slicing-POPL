# This paper must be built with LuaLaTeX: the preamble uses luacolor + lua-ul
# (for \edited{...} review highlighting), which are LuaTeX-only packages.
$pdf_mode = 4;   # 4 = lualatex
$postscript_mode = 0;
$dvi_mode = 0;

# Guard against tools that pass `-pdf` on the command line (e.g. VS Code
# LaTeX Workshop's default recipe), which would override $pdf_mode and force
# pdfLaTeX: redefine the "pdflatex" command itself to run lualatex.
$pdflatex = 'lualatex %O %S';
