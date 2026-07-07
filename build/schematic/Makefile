# Regenerate the build SVGs from their .sch sources, writing into ../ (build/),
# which is where electronics.md references them.
#
#   make            # build all canonical (black) SVGs into ../
#   make png        # also render PNG previews (needs rsvg-convert)
#   make nets       # per-net colour debug views -> ./*_nets.svg (never into ../)
#   make clean      # remove the ../*.png previews and local *_nets.svg
SCH := $(wildcard *.sch)

all:
	python3 schematic.py $(SCH) -o ../

png:
	for f in $(SCH); do rsvg-convert ../$${f%.sch}.svg -o ../$${f%.sch}.png -z 1.3; done

# Per-net colouring: a debug view that paints each electrical net a distinct
# colour (great for spotting accidental shorts or broken nets).
nets:
	python3 schematic.py $(SCH) --color-nets

# Rewrite the .sch sources dropping every position/length parameter whose
# removal keeps ALL the SVGs byte-identical (all sheets passed together so
# defs imported across files stay protected).
cleanup:
	python3 schematic.py --cleanup $(SCH)

.PHONY: all png nets cleanup clean
clean:
	rm -f ../*.png *_nets.svg
