.PHONY: all tools compare clean tidy

.SUFFIXES:
.SECONDEXPANSION:
.PRECIOUS:
.SECONDARY:

ROM := pokepinball.pocket
OBJS := main.o wram.o sram.o

MD5 := md5sum -c

all: $(ROM) compare

ifeq (,$(filter tools clean tidy,$(MAKECMDGOALS)))
Makefile: tools
endif

%.o: dep = $(shell tools/scan_includes $(@D)/$*.asm)
%.o: %.asm $$(dep)
	rgbasm -h -o $@ $<

$(ROM): $(OBJS) contents/contents.link
	rgblink -n $(ROM:.pocket=.sym) -m $(ROM:.pocket=.map) -l contents/contents.link -o $@ $(OBJS)
	rgbfix -jsc -f hg -k 01 -l 0x33 -m 0x1e -p 0 -r 02 -t "POKEPINBALL" -i VPHE $@

# For contributors to make sure a change didn't affect the contents of the rom.
compare: $(ROM)
	@$(MD5) rom.md5

tools:
	$(MAKE) -C tools

tidy:
	rm -f $(ROM) $(OBJS) $(ROM:.pocket=.sym) $(ROM:.pocket=.map)
	$(MAKE) -C tools clean

clean: tidy
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' -o -iname '*.pcm' \) -exec rm {} +

%.interleave.2bpp: %.interleave.png
	rgbgfx -o $@ $<
	tools/gfx --interleave --png $< -o $@ $@

%.2bpp: %.png
	rgbgfx -o $@ $<

%.1bpp: %.png
	rgbgfx -d1 -o $@ $<

%.pcm: %.wav
	tools/pcm -o $@ $<
