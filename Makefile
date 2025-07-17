.POSIX:
.SUFFIXES:

LIBS=-lc -lSDL2_image -lSDL2 -lEGL

betamine:
	hare build $(LIBS) cmd/betamine

run:
	hare run $(LIBS) cmd/betamine

check:
	hare test

clean:
	rm -rf betamine

.PHONY: betamine clean run
