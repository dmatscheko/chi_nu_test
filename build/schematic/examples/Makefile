# Rebuild the example galleries: the two style galleries here plus the
# label-position variants in lpos/ — one Makefile covers both levels
# (schematic.py takes many .sch at once; each SVG lands next to its source).
# lib.sch (defchip library) and the symbols_kit*.sch gallery bodies are
# include-only (no `sheet` line) and are not built directly.
#
#   make            # build all SVGs next to their .sch sources (incl. lpos/)
#   make png        # also render PNG previews (needs rsvg-convert)
#   make clean      # remove SVGs and PNG previews (incl. lpos/)
SCH := symbols_us.sch symbols_iec.sch \
       $(wildcard lpos/symbols_us_*.sch lpos/symbols_iec_*.sch)

all:
	python3 ../schematic.py $(SCH)

png: all
	for f in $(SCH); do rsvg-convert $${f%.sch}.svg -o $${f%.sch}.png -z 1.3; done

.PHONY: all png clean
clean:
	rm -f *.svg *.png lpos/*.svg lpos/*.png
