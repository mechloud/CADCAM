REM Compile LaTeX File with bibliography and glossary

@echo off
setlocal enabledelayedexpansion
set /a counter=1
for /r %%f in (*.tex) do (

	pdflatex %%~nf.tex
	bibtex %%~nf
	makeglossaries %%~nf
	pdflatex %%~nf.tex
	pdflatex %%~nf.tex

	REM DEL %%~nf.log
	REM DEL %%~nf.toc
	REM DEL %%~nf.aux
	REM DEL %%~nf.out
	REM DEL %%~nf.blg
	REM REM DEL %%~nf.bbl
	REM DEL %%~nf.acn
	REM DEL %%~nf.acr
	REM DEL %%~nf.alg
	REM DEL %%~nf.glg
	REM DEL %%~nf.glo
	REM REM DEL %%~nf.gls
	REM DEL %%~nf.ist
	REM DEL %%~nf.lof
	REM DEL %%~nf.lot

	%%~nf.pdf
)
endlocal
cmd /k