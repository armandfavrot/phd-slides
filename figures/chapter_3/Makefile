FIGURES = fig_2 fig_3 fig_4
MANUSCRIPT_DIR = ../../manuscrit/images/chapter_3

.PHONY: all publish
all: publish

# Also synchronise PDFs that are already up to date.
publish: $(addprefix pdf/,$(addsuffix .pdf,$(FIGURES)))
	mkdir -p $(MANUSCRIPT_DIR)
	cp $(addprefix pdf/,$(addsuffix .pdf,$(FIGURES))) $(MANUSCRIPT_DIR)/

pdf/%.pdf: %.tex
	mkdir -p pdf
	pdflatex -interaction=nonstopmode -halt-on-error -output-directory=pdf $<
	mkdir -p $(MANUSCRIPT_DIR)
	cp $@ $(MANUSCRIPT_DIR)/
