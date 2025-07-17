.POSIX:
.SUFFIXES:

LIBS != pkg-config --libs-only-l --libs-only-L sdl3 sdl3-image egl

betamine:
	hare build $(LIBS) cmd/betamine

run:
	hare run $(LIBS) cmd/betamine

check:
	hare test

clean:
	rm -rf betamine

.PHONY: betamine clean run
