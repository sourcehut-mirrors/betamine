use glm;
use world;

def Q = world::CHUNK_WIDTH + 1;
def Q2 = Q * Q;
def NVERTEX = Q2 * (world::CHUNK_HEIGHT + 1);

// Shared vertex position grid for all chunks
//
// Vertex for block index <X,Y,Z> is at
//
// let Q = CHUNK_WIDTH + 1
//
// IX = <Y × Q² + Z × Q + X>
export let chunk_vpos: [NVERTEX]glm::v3 = [[0.0, 0.0, 0.0]...];

@init fn chunk_init() void = {
	def Q = world::CHUNK_WIDTH + 1;
	def Q2 = Q * Q;
	for (let y = 0z; y < world::CHUNK_HEIGHT + 1; y += 1)
	for (let z = 0z; z < world::CHUNK_WIDTH + 1; z += 1)
	for (let x = 0z; x < world::CHUNK_WIDTH + 1; x += 1) {
		let ix = y * Q2 + z * Q + x;
		chunk_vpos[ix] = [x: f32, y: f32, z: f32];
	};
};

// Generate meshes for a given [[world::chunk]].
export fn chunk_geometry() void = {
	void; // TODO
};
