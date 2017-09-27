REM Compile LaTeX File with bibliography and glossary

SET fname=main

pdflatex "%fname%.tex"
makeglossaries "%fname%.tex"
REM BibTeX Line below to be uncommented when the time is right
REM bibtex "%fname%"
pdflatex "%fname%.tex"
pdflatex "%fname%.tex"

DEL "%fname%.log"
DEL "%fname%.toc"
DEL "%fname%.aux"
DEL "%fname%.out"
DEL "%fname%.blg"
DEL "%fname%.bbl"
DEL "%fname%.acn"
DEL "%fname%.acr"
DEL "%fname%.alg"
DEL "%fname%.glg"
DEL "%fname%.glo"
DEL "%fname%.gls"
DEL "%fname%.ist"
DEL "%fname%.lof"
DEL "%fname%.lot"

"%fname%.pdf"