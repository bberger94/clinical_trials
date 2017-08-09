ls ../tables/*.tex | awk '{printf "\\input{%s}\n", $1}' > tables.tex

ls ../figures/*.eps | awk '{printf "\\includegraphics{%s}\n", $1}' > figures.tex

