# Paper

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


# Analysis
WTFURL = https://github.com/evoldoers/wtfgenes.git
WTFGENES = ./wtfgenes/bin/wtfgenes.js

YEAST = wtfgenes/test/data/yeast
GO = go-basic.obo
ASSOCS = gene_association.sgd
MATING = cerevisiae-mating.txt

wtfgenes:
	git clone $(WTFURL)

$(YEAST)/$(GO) $(YEAST)/$(ASSOCS): wtfgenes
	cd $(YEAST); make $(GO) $(ASSOCS)

# The following rules use biomake's multi-wildcard pattern-matching
# https://github.com/evoldoers/biomake
mixing.f$F-s$S-j$J-r$R.json: $(YEAST)/$(GO) $(YEAST)/$(ASSOCS)
	$(WTFGENES) -F $F -S $S -J $J -R $R -o $(YEAST)/$(GO) -a $(YEAST)/$(ASSOCS) -g $(YEAST)/$(MATING) -l mixing >$@

$(AUTO).$(PARAMS).csv: mixing.$(PARAMS).json
	node -e 'var fs = require ("fs"), json = JSON.parse (fs.readFileSync ("$<")), auto = json.mcmc.$(AUTO); if (auto[0]) auto = auto[0]; console.log ("r,$(AUTO)"); Object.keys(auto).forEach (function (r) { console.log (r + "," + auto[r]) })' >$@

