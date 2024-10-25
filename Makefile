.POSIX:
.SUFFIXES:

LIBS=-lc -lSDL2_image -lSDL2_mixer -lSDL2 -lEGL

betamine:
	hare build $(LIBS) cmd/betamine

run:
	hare run $(LIBS) cmd/betamine

clean:
	rm -rf betamine

.PHONY: betamine clean run
