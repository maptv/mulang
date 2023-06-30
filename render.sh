#! /bin/sh

quarto convert "$1"

quarto render "$1" --profile python --metadata engine:jupyter --output "${1%.*}_quarto_python.ipynb"

quarto render "$1" --profile r --metadata engine:jupyter --output "${1%.*}_quarto_r.ipynb"

quarto render "$1" --profile julia --metadata engine:jupyter --output "${1%.*}_quarto_julia.ipynb"

jupytext "${1%.*}_quarto_python.ipynb" --to py --output "${1%.*}.py" --set-kernel python3

jupytext "${1%.*}_quarto_r.ipynb" --to R --output "${1%.*}.R" --set-kernel ir

jupytext "${1%.*}_quarto_julia.ipynb" --to jl --output "${1%.*}.jl" --set-kernel julia-1.9

# I use jupytext to execute the notebooks because I put eval: false in the julia code chunk in the qmd to circumvent the fact that knitr cannot execute julia
# If I did not also want to include julia in this example I would just use the first quarto notebooks and I forgo using jupytext altogether
jupytext "${1%.*}.py" --output "${1%.*}_jupytext_python.ipynb" --execute --set-kernel python3

jupytext "${1%.*}.R" --output "${1%.*}_jupytext_r.ipynb" --execute --set-kernel ir

jupytext "${1%.*}.jl" --output "${1%.*}_jupytext_julia.ipynb" --execute --set-kernel julia-1.9

# Replace code chunks with embed short codes
cat "${1%.*}.qmd"  | gsed '/^```{/,/^```$/ { # set a range and say what should happen in that range below
    /^```{.*}$\|#| tags:/!d; # delete all but the first line and tags line of all code chunks
    N;s/\n//g; # join pairs of lines in all code blocks
    s/^```{\(.*\)}#| tags: \[\(.*\)\]/{{< embed jupytext_\1\.ipynb#\2 >}}/g; # replace code chunk and comment syntax with shortcode syntax
    /{{< embed .*\.ipynb#.* >}}/!d # delete anything that is not an embed shortcode with a tag
}' | sed "s/{{< embed \(.*\)\.ipynb#\(.*\) >}}/{{< embed ${1%.*}_\1\.ipynb#\2 >}}/g"> "${1%.*}_embed.qmd"

# Here is the above command in a single line without inline comments
# replace code chunks with embed short codes by setting a range, deleting all but two lines, joining the lines, substituting, and deleting anything that does not match the shortcode pattern
# cat "${1%.*}.qmd"  | gsed '/^```{/,/^```$/ { /^```{.*}$\|#| tags:/!d; N;s/\n//g; s/^```{\(.*\)}#| tags: \[\(.*\)\]/{{< embed _\1\.ipynb#\2 >}}/g; /{{< embed .*\.ipynb#.* >}}/!d }' | sed "s/{{< embed \(.*\)\.ipynb#\(.*\) >}}/{{< embed ${1%.*}\1\.ipynb#\2 >}}/g" > "${1%.*}_embed.qmd"

# Ranges example: This deletes all code chunks
# cat mulang.qmd | sed '/^```{/,/^```$/d'\n

# create all output files
quarto render "${1%.*}.qmd" --profile knitr --metadata engine:knitr

# recreate html output file with embedded notebooks
quarto render "${1%.*}_embed.qmd" --profile knitr --metadata engine:knitr --to html --output "${1%.*}.html"
