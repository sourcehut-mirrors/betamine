use fmt;
use os;
use world;
use world::{mode};

export fn main() void = {
	const w = world::open(os::args[1])!;
	const level = &w.level;
	fmt::printfln("Level name: {}", level.name)!;
	fmt::printfln("Seed: {}", level.seed)!;
	fmt::printfln("Spawn: <{},{},{}>",
		level.spawn.0, level.spawn.1, level.spawn.2)!;

	fmt::println()!;

	fmt::println("world::get(..., mode::LOAD)")!;
	let at: world::coords3D = (0, 0, 0);
	for (at.1 < 8; at.1 += 1) {
		let voxel = world::voxel { ... };
		world::get(&w, &voxel, at, mode::LOAD)!;
		fmt::printfln("block at <{},{},{}>: {}",
			at.0, at.1, at.2, voxel.id)!;
	};

	fmt::println("world::get(..., mode::EMPTY)")!;
	let at: world::coords3D = (100, 0, 100);
	let voxel = world::voxel { ... };
	world::get(&w, &voxel, at, mode::EMPTY)!;
	fmt::printfln("block at <{},{},{}>: {}",
		at.0, at.1, at.2, voxel.id)!;
	world::get(&w, &voxel, at, mode::LOAD)!;
	fmt::printfln("block at <{},{},{}>: {}",
		at.0, at.1, at.2, voxel.id)!;

	fmt::println()!;

	fmt::println("world::get_chunk")!;
	for (let x = -1; x <= 1; x += 1)
	for (let z = -1; z <= 1; z += 1) {
		const chunk = world::get_chunk(&w, (x, z), mode::LOAD)!;
		fmt::printfln("<{}, {}>: last update: {}",
			chunk.coords.0, chunk.coords.1,
			chunk.last_update)!;
	};
};
