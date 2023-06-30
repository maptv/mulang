#! /bin/sh

quarto convert "$1"

quarto render "$1" --profile python --metadata engine:jupyter --output "${1%.*}_quarto_python.ipynb"

quarto render "$1" --profile r --metadata engine:jupyter --output "${1%.*}_quarto_r.ipynb"

jupytext "${1%.*}_quarto_python.ipynb" --to py --output "${1%.*}.py" --set-kernel python3

jupytext "${1%.*}_quarto_r.ipynb" --to R --output "${1%.*}.R" --set-kernel ir

jupytext "${1%.*}.py" --output "${1%.*}_jupytext_python.ipynb" --execute --set-kernel python3

jupytext "${1%.*}.R" --output "${1%.*}_jupytext_r.ipynb" --execute --set-kernel ir

# WIP: replace code chunks with embed short codes
# cat mulang.qmd | sed 's/```{\(.*\)}/{{< embed mulang_\1/g;s/#| tags: \[\(.*\)\]/#\1.ipynb >}}/g'\n

# cat mulang.qmd | awk -v RS='```' '!/{julia}|{python}|{r}/' > "${1%.*}_embed.qmd"

# printf "\n\n# Python code:\n\n{{< embed ${1%.*}_python.ipynb echo=true >}}\n\n# R code:\n\n{{< embed ${1%.*}_r.ipynb echo=true >}}" >> "${1%.*}_embed.qmd"

# create all output files
quarto render "${1%.*}.qmd" --profile knitr --metadata engine:knitr

# recreate html output file with embedded notebooks
# quarto render "${1%.*}_embed.qmd" --profile knitr --metadata engine:knitr --to html --output "${1%.*}.html"
