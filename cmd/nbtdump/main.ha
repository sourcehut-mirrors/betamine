use fmt;
use io;
use nbt;
use nbt::{nbt_tag};
use os;
use types;

export fn main() void = {
	const rd = nbt::read(os::stdin);
	nbt::dump(os::stdout, &rd)!;
};
