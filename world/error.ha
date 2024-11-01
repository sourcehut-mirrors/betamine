use errors;
use fs;
use io;

// The requested coordinates exceed the vertical range of the world.
export type range = !void;

// Errors produced by the [[world]] module.
export type error = !(
	io::error |
	fs::error |
	errors::error |
	range
);
