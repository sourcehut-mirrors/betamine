use fs;
use io;
use os;
use sort;

// A game world on disk.
export type world = struct {
	basedir: str,
	level: level,

	// List of loaded regions sorted by X and Z coordinate (in that order)
	regions: [][]region,
};

// Opens a world directory from disk.
export fn world_open(path: str) (world | fs::error | io::error) = {
	abort(); // TODO
};
