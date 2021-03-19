MAIN=""

ifeq ($(MAIN), "")
	ALL=doc.tex example/example.tex
	ALLDEP=doc example
else
	ALL=$(MAIN) doc.tex example/example.tex
	ALLDEP=main doc example
endif

NAME = xustthesis
UPSTREAM = ustcthesis
CLSFILES = $(NAME).cls

SHELL = bash
LATEXMK = latexmk -xelatex
VERSION = $(shell cat $(NAME).cls | egrep -o "\[\d\d\d\d/\d\d\/\d\d v.+\]" \
	  | egrep -o "v\S+")
TEXMF = $(shell kpsewhich --var-value TEXMFHOME)

.PHONY: help all main doc example clean cleanall FORCE_MAKE

help:
	-@echo "Usage:"
	-@echo "    help:     help info"
	-@echo "    all:      compile all tex (main, doc and example)"
	-@echo "    doc:      compile doc tex"
	-@echo "    example:  compile example tex"
	-@echo "    clean:    clean all files (except pdf)"
	-@echo "    cleanall: clean all files"
	-@echo ""
	-@echo "Varable:"
	-@echo "    MAIN: set main tex"

all: $(ALLDEP)

main: $(MAIN) $(CLSFILES) FORCE_MAKE
	$(LATEXMK) $<

doc:
	$(LATEXMK) doc.tex

example: example/example.tex $(CLSFILES)
	$(LATEXMK) $<

clean: FORCE_MAKE
	$(LATEXMK) -c $(ALL)
	rm -rf *.run.xml

cleanall: FORCE_MAKE
	$(LATEXMK) -C $(ALL)
	rm -rf *.run.xml *.bbl
