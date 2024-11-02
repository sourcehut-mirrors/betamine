use gfx;
use glm;

let clouds = gfx::texture { ... };

def DRIFT_FACTOR = 1000;
def CLOUD_Y = 112.1;
def CLOUD_SCALE = 8.0;
def CLOUD_ALPHA = 0.75;

// Initializes the cloud layer.
export fn clouds_init(state: *state) void = {
	clouds = gfx::texture_load("assets/environment/clouds.png")!;

	append(state.layers, alloc(layer {
		update = &no_update,
		draw = &clouds_draw,
	}));
};

fn clouds_draw(layer: *layer, state: *state) void = {
	let time = state.ticks % (clouds.w: u64 * 8 * DRIFT_FACTOR);
	const drift = time: f32 / DRIFT_FACTOR: f32;

	let model = glm::M4_IDENT;
	let mvp = glm::M4_IDENT;

	glm::scale(&model, &glm::v3_new_fill(clouds.w: f32 * CLOUD_SCALE));
	glm::translate(&model, &glm::v3_new(
		drift,
		CLOUD_Y,
		0.0,
	));
	glm::m4_mul_to(&state.vp, &model, &mvp);
	gfx::render_plane(&mvp, &clouds, &glm::v4_new(1.0, 1.0, 1.0, CLOUD_ALPHA));

	// Again at -drift so it wraps correctly
	glm::scale(&model, &glm::v3_new_fill(clouds.w: f32 * CLOUD_SCALE));
	glm::translate(&model, &glm::v3_new(
		clouds.w: f32 * CLOUD_SCALE - drift,
		CLOUD_Y,
		0.0,
	));
	glm::m4_mul_to(&state.vp, &model, &mvp);
	gfx::render_plane(&mvp, &clouds, &glm::v4_new(1.0, 1.0, 1.0, CLOUD_ALPHA));
};
