#! /bin/sh

quarto render "$1" --profile python --metadata engine:jupyter --output "${1%.*}_python.ipynb"

quarto render "$1" --profile r --metadata engine:jupyter --output "${1%.*}_r.ipynb"

quarto render "$1" --profile knitr --metadata engine:knitr
