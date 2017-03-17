# Paper

all preprint: preprint.pdf.open

clean:
	rm *.toc *.log *.blg *.out *.pdf *.aux *.nav *.vrb *.snm *~

%.open: %
	open $<

%.pdf: $(wildcard *.tex) references.bib
	pdflatex $*.tex
	bibtex $*
	pdflatex $*.tex
	pdflatex $*.tex

.SECONDARY:


# Analysis of mixing properties of different kernels on 17-gene yeast dataset
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

# The next two rules use biomake's multi-wildcard pattern-matching
# https://github.com/evoldoers/biomake
mixing.f$F-s$S-j$J-r$R.json: $(YEAST)/$(GO) $(YEAST)/$(ASSOCS)
	$(WTFGENES) -F $F -S $S -J $J -R $R -o $(YEAST)/$(GO) -a $(YEAST)/$(ASSOCS) -g $(YEAST)/$(MATING) -l mixing >$@

$(AUTO)AutoCorrelation.$(PARAMS).csv: mixing.$(PARAMS).json
	node -e 'var fs = require ("fs"), json = JSON.parse (fs.readFileSync ("$<")), auto = json.mcmc.$(AUTO)AutoCorrelation; if (auto[0]) auto = auto[0]; console.log ("tau,$(AUTO)AutoCorrelation"); Object.keys(auto).forEach (function (tau) { console.log (tau + "," + auto[tau]) })' >$@

KERNELS = f1-s0-j0-r0 f1-s1-j0-r0 f1-s0-j1-r0 f1-s0-j0-r1 f1-s1-j1-r0
CSV = $(patsubst %,logLikeAutoCorrelation.%.csv,$(KERNELS)) $(patsubst %,termAutoCorrelation.%.csv,$(KERNELS))

csv: $(CSV)

# R
makeplot.R:
	node -e 'var kernels = "$(KERNELS)".split(" "); console.log ("require(\"ggplot2\")"); function makePlot (v, title) { var frames = []; kernels.forEach (function (k) { var tag = k.split("-").join(""), match = /f(.*)-s(.*)-j(.*)-r(.*)/.exec(k), moves = ["flip","step","jump","randomize"], labels = []; moves.forEach (function (move, n) { if (match[n+1] !== "0") { labels.push ((match[n+1] === "1" ? "" : (match[n+1]+"*")) + move) } }); var frame = "data." + tag; frames.push(frame); console.log(frame+" = read.csv(\""+v+"."+k+".csv\")\n"+frame+"$$Kernel = \""+labels.join(" + ")+"\"\n") }); console.log("dat = rbind("+frames.join(",")+")\n\nggplot(aes(x=tau, y="+v+", color=Kernel), data=dat) + geom_line(aes(linetype=Kernel)) + geom_point(aes(shape=Kernel)) + xlim(0,1024) + ylim(0,1) + ylab(\""+title+"\") + xlab(\"Samples per term\") + theme(legend.position = c(.85,.85))\nggsave(\""+v+".pdf\")\n") } makePlot("logLikeAutoCorrelation","Log-likelihood autocorrelation"); makePlot("termAutoCorrelation","Term variable autocorrelation") ' >$@

logLikeAutoCorrelation.pdf termAutoCorrelation.pdf: makeplot.R $(CSV)
	R -f makeplot.R

# Simulation on yeast dataset
sim.t$(TERMS).json:
	$(WTFGENES) -o $(YEAST)/$(GO) -a $(YEAST)/$(ASSOCS) -A $(TERMS) -O .001 -E .01 -B 100 -x -s 100 >$@

allsim.t$(MAXTERMS).csv: $(addprefix sim.t,$(addsuffix .json,$(iota $(MAXTERMS))))
	node -e 'fs=require("fs");console.log("method,terms,threshold,recall,specificity,precision,fpr,precision_n");for(nTerms=1;nTerms<=$(MAXTERMS);++nTerms){d=JSON.parse(fs.readFileSync("sim.t"+nTerms+".json"));["hypergeometric","model"].map(function(method){d.analysis[method].forEach(function(row){console.log([method,nTerms,row.threshold,row.recall.mean,row.specificity.mean,row.precision.mean,row.fpr.mean,row.precision.n].join(","))})})}' >$@

allsim%pdf: allsim.t4.csv allsim%R
	R -f allsim$*R
