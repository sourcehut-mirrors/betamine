use fmt;
use os;
use world;

export fn main() void = {
	const region = world::region_open(os::args[1])!;
	defer world::region_close(&region);

	fmt::println("Chunks present:")!;
	for (let x = 0; x < 32; x += 1)
	for (let y = 0; y < 32; y += 1) {
		const chunk = match (world::region_getchunk(&region, x, y)) {
		case let c: *world::chunk_header =>
			yield c;
		case null =>
			continue;
		};

		const data = world::chunk_data(chunk);
		fmt::printfln("<{},{}>: {} bytes", x, y, len(data))!;
	};
};
