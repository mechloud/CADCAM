# Found this bash script on https://ubuntuforums.org/showthread.php?t=1185117


#! /bin/bash

ERROR="Too few arguments : no file name specified"
[[ $# -eq 0 ]] && echo $ERROR && exit # no args? ... print error and exit

# check that the file exists
if [ -f $1.tex ] 
then
# if it exists then latex it twice, dvips, then ps2pdf, then remove all the unneeded files
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
else
# otherwise give this output line with a list of available tex files
echo the file doesnt exist butthead! Choose one of these:
ls *.tex
fi
