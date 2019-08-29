#!/bin/bash
latexdiff ../submitted_version/mcnitt_tuta.tex mcnitt_tuta.tex > main_diff.tex
latexdiff ../submitted_version/mcnitt_tuta_supplementary.tex mcnitt_tuta_supplementary.tex > supp_diff.tex
