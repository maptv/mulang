#! /bin/sh

quarto convert "$1"

jupytext "$1" --output "${1%.*}.py" --kernel python3

jupytext "$1" --output "${1%.*}.R" --kernel ir

jupytext "$1" --output "${1%.*}.jl" --kernel julia-1.9

quarto render "$1" --profile python --metadata engine:jupyter --output "${1%.*}_python.ipynb"

quarto render "$1" --profile r --metadata engine:jupyter --output "${1%.*}_r.ipynb"

quarto render "$1" --profile knitr --metadata engine:knitr

printf "Python code:\n\n{{< embed ${1%.*}_python.ipynb echo=true >}}\n\n# R code:\n\n{{< embed ${1%.*}_r.ipynb echo=true >}}" > "${1%.*}_embed.qmd"

quarto render "${1%.*}_embed.qmd" --profile embed --metadata engine:knitr --to html
