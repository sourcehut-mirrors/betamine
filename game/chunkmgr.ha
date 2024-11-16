use engine;
use gfx;
use gl;
use gl::{glDrawArrays};
use glm;
use log;
use sort;
use time;
use time::{clock};
use types;
use world;
use world::{CHUNK_WIDTH, CHUNK_HEIGHT, mode};

// TODO: Make this a configurable option
def RENDER_DISTANCE = 12;

// Maximum amount of time spent on tesselation in a single update
// (No more than half a frame at 60 FPS)
def MAX_TESS_TIME = 8 * time::MILLISECOND;

// Delay to debounce unloading chunk meshes.
def UNLOAD_DELAY = 30 * 1000;

// Neighbors of a chunk.
export type chunk_neighbor = enum uint {
	N	= 1 << 0,
	NE	= 1 << 1,
	E	= 1 << 2,
	SE	= 1 << 3,
	S	= 1 << 4,
	SW	= 1 << 5,
	W	= 1 << 6,
	NW	= 1 << 7,

	NONE	= 0,
	ALL	= N | E | S | W | NE | SE | SW | NW,
};

// The chunk manager manages loaded chunks from the world, schedules
// tesselation and manages meshes, and handles loading and unloading when
// necessary.
export type chunk_manager = struct {
	layer,
	player_cc: world::coords2D,
	world: *world::world,
	meshes: []chunk,
	queue: []const *world::chunk,
};

// A loaded chunk in the game engine.
export type chunk = struct {
	chunk: const *world::chunk,
	mesh: gfx::chunk_mesh,
	aabb: [2]glm::v3,
	unload: u32,
};

// Initializes a chunk manager for the given [[world]].
export fn chunk_manager_init(state: *state) void = {
	const chunkmgr = alloc(chunk_manager {
		update = &chunkmgr_update,
		draw = &chunkmgr_draw,
		world = &state.world,
		player_cc = (types::INT_MIN, types::INT_MIN),
		...
	});
	append(state.modules, chunkmgr);
	append(state.layers, chunkmgr);
	state.chunkmgr = chunkmgr;
};

fn chunkmgr_update(mod: *module, state: *state) void = {
	let mgr = mod: *chunk_manager;

	const player: world::coords3D = (
		state.camera.pos[0]: int,
		state.camera.pos[1]: int,
		state.camera.pos[2]: int,
	);
	let coords = world::world_to_chunk(player, null);
	if (!world::coords2D_equal(mgr.player_cc, coords)) {
		mgr.player_cc = coords;
	};

	if (len(mgr.queue) != 0) {
		chunkmgr_procqueue(mgr);
	};

	chunkmgr_procunload(mgr, state);
};

fn chunkmgr_draw(layer: *layer, state: *state) void = {
	const mgr = layer: *chunk_manager;
	state.nchunk = len(mgr.meshes);
	state.chunks_rendered = 0;
	state.nvertex = 0;

	for (let chunk &.. mgr.meshes) {
		chunkmgr_drawchunk(state, chunk, false);
	};
	for (let chunk &.. mgr.meshes) {
		chunkmgr_drawchunk(state, chunk, true);
	};
};

fn chunkmgr_drawchunk(state: *state, c: *chunk, trans: bool) void = {
	if (c.unload != types::U32_MAX) {
		return;
	};
	if (!glm::aabb_frustrum(&c.aabb, &state.frustrum)) {
		return;
	};

	const mesh = &c.mesh;
	const (x, z) = c.chunk.coords;

	let mvp = glm::M4_ZERO;
	let model = glm::M4_IDENT;
	glm::translate(&model, &glm::v3_new(
		(x * world::CHUNK_WIDTH): f32,
		0.0,
		(z * world::CHUNK_WIDTH): f32,
	));
	glm::m4_mul_to(&state.vp, &model, &mvp);

	gfx::terrain_bind(&mvp);

	const npoly =
		if (trans)	mesh.ntransparent
		else		mesh.nopaque;

	if (npoly > 0) {
		gfx::chunk_begin(mesh, trans);
		glDrawArrays(gl::GL_TRIANGLES, 0, npoly: i32);
		state.nvertex += npoly * 3;
	};

	if (!trans) {
		state.chunks_rendered += 1;
	};
};

// Queues a chunk for tesselation, and optionally its neighbors as well.
fn chunkmgr_enqueue(
	mgr: *chunk_manager,
	chunk: const *world::chunk,
	neighbors: chunk_neighbor = chunk_neighbor::NONE,
) void = {
	if (world::chunk_isempty(chunk)) {
		log::println("[chunkmgr] Attempted to schedule empty chunk");
		return;
	};

	const (x, z) = chunk.coords;
	chunkmgr_queue_insert(mgr, chunk);

	const adjacent: [_]world::coords2D = [
		( 0, -1),	// N
		( 1, -1),	// NE
		( 1,  0),	// E
		( 1,  1),	// SE
		( 0,  1),	// S
		(-1,  1),	// SW
		(-1,  0),	// W
		(-1, -1),	// NW
	];
	for (let i = 0u; i < len(adjacent); i += 1) {
		if (neighbors & (1 << i) == 0) {
			continue;
		};

		const offs = adjacent[i];
		const ncoord: world::coords2D = (x + offs.0, z + offs.1);
		const neighbor = match (world::get_chunk(mgr.world,
			ncoord, world::mode::ERROR)) {
		case let c: *world::chunk =>
			yield c;
		case world::nochunk =>
			continue;
		case => abort();
		};

		chunkmgr_queue_insert(mgr, neighbor, true);
	};
};

fn chunkmgr_queue_insert(
	mgr: *chunk_manager,
	chunk: const *world::chunk,
	is_neighbor: bool = false,
) void = {
	const ix = sort::lbisect(mgr.queue, size(*world::chunk),
		&chunk, &world::coords2D_cmp);
	if (ix < len(mgr.queue) && mgr.queue[ix] == chunk) {
		return;
	};
	log::printfln("[chunkmgr] schedule {}tesselation at <{},{}> {}",
		if (is_neighbor) "neighbor for " else "",
		chunk.coords.0, chunk.coords.1,
		chunk);
	insert(mgr.queue[ix], chunk);
};

// Schedules a chunk for unloading.
fn chunkmgr_unload(mgr: *chunk_manager, coords: world::coords2D) void = {
	for (let mesh &.. mgr.meshes) {
		if (world::coords2D_equal(coords, mesh.chunk.coords)) {
			log::printfln("[chunkmgr] schedule unload <{},{}>",
				coords.0, coords.1);
			mesh.unload = 0;
			break;
		};
	};
};

// Schedules chunks for tesselation based on the player location. Assumes an
// on-disk (not in-memory) world.
fn chunkmgr_schedule(mgr: *chunk_manager, state: *state) void = {
	def RD = RENDER_DISTANCE;
	let coords = mgr.player_cc;
	const min: world::coords2D = (coords.0 - RD, coords.1 - RD);
	const max: world::coords2D = (coords.0 + RD, coords.1 + RD);
	for (let x = min.0; x <= max.0; x += 1)
	for (let z = min.1; z <= max.1; z += 1) {
		const i = chunkmgr_bisect(mgr, (x, z));
		if (i < len(mgr.meshes) && world::coords2D_equal((x, z),
				mgr.meshes[i].chunk.coords)) {
			mgr.meshes[i].unload = types::U32_MAX;
			continue;
		};

		const chunk = world::get_chunk(mgr.world, (x, z), mode::LOAD)!;
		if (world::chunk_isempty(chunk)) {
			continue;
		};

		chunkmgr_queue_insert(mgr, chunk);
	};

	for (let i = 0z; i < len(mgr.meshes); i += 1) {
		let mesh = &mgr.meshes[i];
		const coords = mesh.chunk.coords;
		if (coords.0 >= min.0 && coords.1 >= min.1
			&& coords.0 <= max.0 && coords.1 <= max.1) {
			continue;
		};
		mesh.unload = state.frame_time + UNLOAD_DELAY;
	};
};

fn chunkmgr_procunload(mgr: *chunk_manager, state: *state) void = {
	for (let i = 0z; i < len(mgr.meshes); i += 1) {
		const mesh = &mgr.meshes[i];
		const coords = mesh.chunk.coords;
		if (state.frame_time < mesh.unload) {
			continue;
		};

		log::printfln("[chunkmgr] unload <{},{}>", coords.0, coords.1);
		gfx::chunk_finish(&mesh.mesh);
		world::put_chunk(mgr.world, mesh.chunk);
		static delete(mgr.meshes[i]);
		i -= 1;
	};
};

fn chunkmgr_procqueue(mgr: *chunk_manager) void = {
	static let tmesh = engine::chunk_mesh { ... };

	const start = time::now(clock::MONOTONIC);
	const deadline = time::add(start, MAX_TESS_TIME);
	for (len(mgr.queue) > 0) {
		const now = time::now(clock::MONOTONIC);
		if (time::compare(deadline, now) < 0) {
			log::printfln("[chunkmgr] tesselation deadline elapsed; {} remaining", len(mgr.queue));
			break;
		};

		const next = mgr.queue[len(mgr.queue)-1];
		static delete(mgr.queue[len(mgr.queue)-1]);

		const coords = next.coords;
		tmesh.vert_opaque = tmesh.vert_opaque[..0];
		tmesh.vert_translucent = tmesh.vert_translucent[..0];
		engine::chunk_genmesh(mgr.world, next, &tmesh);

		const mesh = gfx::chunk_init(&tmesh);
		const aabb: [2]glm::v3 = [
			[
				(coords.0 * CHUNK_WIDTH): f32,
				0.0,
				(coords.1 * CHUNK_WIDTH): f32,
			],
			[
				(coords.0 * CHUNK_WIDTH + CHUNK_WIDTH): f32,
				128.0,
				(coords.1 * CHUNK_WIDTH + CHUNK_WIDTH): f32,
			],
		];

		const ix = chunkmgr_bisect(mgr, coords);
		if (ix < len(mgr.meshes) && mgr.meshes[ix].chunk == next) {
			// Update chunk mesh
			gfx::chunk_finish(&mgr.meshes[ix].mesh);
			mgr.meshes[ix] = chunk {
				chunk = next,
				mesh = mesh,
				aabb = aabb,
				unload = types::U32_MAX,
			};
		} else {
			// Take reference for new mesh
			world::chunk_ref(next);

			insert(mgr.meshes[ix], chunk {
				chunk = next,
				mesh = mesh,
				aabb = aabb,
				unload = types::U32_MAX,
			});
		};

		// Put reference held by queue
		world::put_chunk(mgr.world, next);

		const tend = time::now(clock::MONOTONIC);
		log::printfln("[chunkmgr] tesselate <{},{}> {}ms",
			next.coords.0, next.coords.1,
			time::diff(now, tend) / time::MILLISECOND);
	};
};

fn chunkmgr_bisect(mgr: *chunk_manager, key: world::coords2D) size = {
	return sort::lbisect(mgr.meshes, size(chunk), &key, &chunk_cmp);
};

fn chunk_cmp(a: const *opaque, b: const *opaque) int = {
	const key = a: const *world::coords2D;
	const val = b: const *chunk;
	return world::coords2D_cmp(&key, &val.chunk);
};
