.SUFFIXES: .cr .png

PNGS = etc/examples/1.png etc/examples/2.png \
	etc/examples/3.png etc/examples/4.png \
	etc/examples/5.png

.cr.png:
	crystal run --define png $< > $@

default: $(PNGS)
