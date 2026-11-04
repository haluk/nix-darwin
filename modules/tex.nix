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
    aobs-tikz # overlay-beamer-styles TikZ library
    tikzmark # mark positions in text for TikZ overlays
    tikzpingus # penguins drawn in TikZ
    fancyqr # styled QR codes
    qrcode # fancyqr dependency
    pict2e # fancyqr dependency
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
    tikzfill # tcolorbox skins dependency (tikzfill.image.sty)
    beamer # slides
    beamertheme-metropolis
    pdfpc # speaker notes and metadata for the pdfpc presenter
    hyperxmp # pdfpc dependency
    xstring # pdfpc dependency
    atenddvi # hyperxmp dependency
    ifmtarg # hyperxmp dependency
    fontawesome5 # icons

    # Code listings
    listings
    listingsutf8 # UTF-8 input for listings; tcolorbox's listingsutf8 library
    lstaddons # lstautogobble
    accsupp # copy-paste text for listings (e.g. non-copyable line numbers)
    lstfiracode # Fira Code ligatures in listings
    minted # needs -shell-escape
    fvextra
    upquote

    # Fonts
    collection-fontsrecommended
    bera # berasans, beraserif, beramono
  ]);
in
{
  environment.systemPackages = [
    tex
    pkgs.pdfpc # presenter console for Beamer slides
  ];
}
