# TeX Live for LaTeX documents built with latexmk + lualatex.
# Names are TeX Live packages, not LaTeX ones: a .sty missing here is usually
# inside a bigger package (`tlmgr info --list <pkg>` or texlive.pkgs.<pkg>).
{ pkgs, ... }:

let
  tex = pkgs.texliveSmall.withPackages (ps: with ps; [
    # Build tools
    latexmk
    biber
    chktex # linter; Doom's latex module uses it
    latexindent # formatter; Doom's latex module uses it
    texcount # word counts

    # LuaLaTeX, Unicode, and mathematics
    collection-luatex
    fontspec
    unicode-math
    mathtools
    amsmath
    amsfonts # includes amssymb
    siunitx
    amscls # amsthm
    thmtools # theorem/proof environments on top of amsthm
    derivative # \odv, \pdv; physics clashes with siunitx's \qty
    esint # extra integral signs
    lm-math # math fonts for unicode-math
    tex-gyre-math
    algorithms # algorithm float
    algorithmicx # algpseudocode
    algorithm2e

    # Bibliographies and references
    biblatex
    csquotes
    cleveref
    glossaries
    glossaries-extra
    acro # acronyms
    translations # acro dependency
    imakeidx # indexes

    # Diagrams, figures, and tables (longtable comes with texliveSmall's tools)
    pgf # TikZ
    standalone
    float
    caption # includes subcaption
    booktabs
    pgfplots # data plots in TikZ
    tikz-cd # commutative diagrams
    multirow
    makecell
    threeparttable # table notes
    tabularray
    ninecolors # tabularray dependency
    nicematrix
    csvsimple # tables straight from CSV
    pdfpages # include PDF pages

    # Document layout and typography
    geometry
    fancyhdr
    titlesec
    enumitem
    microtype
    xcolor
    hyperref
    bookmark
    koma-script
    setspace
    parskip
    ragged2e
    lineno # line numbers for drafts/reviews
    todonotes # margin notes for drafts
    lipsum # filler text
    tcolorbox # boxed callouts; also styles minted listings
    beamer # slides
    beamertheme-metropolis
    fontawesome5 # icons

    # Code listings
    listings
    minted # needs -shell-escape
    fvextra
    upquote

    # Fonts
    collection-fontsrecommended
  ]);
in
{
  environment.systemPackages = [ tex ];
}
