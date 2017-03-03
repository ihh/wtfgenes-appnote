
all: main.pdf.open

preprint: preprint.pdf.open

clean:
	rm *.toc *.log *.blg *.out *.pdf *.aux *.nav *.vrb *.snm *~

%.open: %
	open $<

%.pdf: %.tex paper.tex references.bib
	pdflatex $<
	bibtex $*
	pdflatex $<
	pdflatex $<

.SECONDARY:
