use glm;

// TODO: "fancy" clouds
let clouds = texture { ... };

fn clouds_init() void = {
	clouds = texture_load("assets/environment/clouds.png")!;
};

def DRIFT_FACTOR = 1000;
def CLOUD_Y = 112.0;
def CLOUD_SCALE = 8.0;
def CLOUD_ALPHA = 0.75;

// Renders the cloud layer.
export fn render_clouds(
	vp: *glm::m4,
	time: u64,
) void = {
	// TODO: This needs some work
	// 1. Something is wrong with the modulo logic
	// 2. We need to display clouds above the player regardless of their
	//    position in the world

	time %= clouds.w: u64 * 8 * DRIFT_FACTOR;
	const drift = time: f32 / DRIFT_FACTOR: f32;

	let model = glm::M4_IDENT;
	let mvp = glm::M4_IDENT;

	glm::scale(&model, &glm::v3_new_fill(clouds.w: f32 * CLOUD_SCALE));
	glm::translate(&model, &glm::v3_new(
		drift,
		CLOUD_Y,
		0.0,
	));
	glm::m4_mul_to(vp, &model, &mvp);
	render_plane(&mvp, &clouds, &glm::v4_new(1.0, 1.0, 1.0, CLOUD_ALPHA));

	// Again at -drift so it wraps correctly
	glm::scale(&model, &glm::v3_new_fill(clouds.w: f32 * CLOUD_SCALE));
	glm::translate(&model, &glm::v3_new(
		clouds.w: f32 * CLOUD_SCALE - drift,
		CLOUD_Y,
		0.0,
	));
	glm::m4_mul_to(vp, &model, &mvp);
	render_plane(&mvp, &clouds, &glm::v4_new(1.0, 1.0, 1.0, CLOUD_ALPHA));
};
