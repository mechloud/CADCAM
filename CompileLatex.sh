# Found this bash script on https://ubuntuforums.org/showthread.php?t=1185117


#! /bin/bash

ERROR="Too few arguments : no file name specified"
[[ $# -eq 0 ]] && echo $ERROR && exit # no args? ... print error and exit

# check that the file exists
if [ -f $1.tex ] 
then
# if it exists then latex, bibtex, makeglossaries, then run latex twice again.
    pdflatex $1.tex
    bibtex $1
    makeglossaries $1
    pdflatex $1.tex
    pdflatex $1.tex

# these lines can be appended to delete other files, such as *.out
rm *.aux
rm *.log
rm *.toc
rm *.lof
rm *.acn
rm *.acr
rm *.blg
rm *.ist
rm *.lot
rm *.alg
rm *.bbl

evince $1.pdf
else
# otherwise give this output line with a list of available tex files
echo the file doesnt exist butthead! Choose one of these:
ls *.tex
fi
