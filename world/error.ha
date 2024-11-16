use errors;
use fs;
use io;

// The requested coordinates exceed the vertical range of the world.
export type range = !void;

// mode == mode::ERROR and there was no chunk available at the requested
// coordinates.
export type nochunk = !void;

// Errors produced by the [[world]] module.
export type error = !(
	io::error |
	fs::error |
	errors::error |
	range |
	nochunk
);
