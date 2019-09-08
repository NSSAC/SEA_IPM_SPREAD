#!/bin/bash
pdftk \
    main_diff.pdf \
    supp_diff.pdf \
    cat output differences_between_orginal_revised.pdf

zip mcnitt_tuta_revised_version.zip \
    mcnitt_tuta.pdf \
    mcnitt_tuta_supplementary.pdf \
    differences_between_orginal_revised.pdf \
    review_response.pdf
