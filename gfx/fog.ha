use glm;
use gl;
use gl::{
	glBindBuffer,
	glBindBufferBase,
	glBufferData,
	glGenBuffers,
};

// Fog render parameters
export type fog_params = struct {
	factor: f32,
	near: f32,
	far: f32,
	@offset(size([4]f32)) color: glm::v3,
};

let fog_ubo = 0u;

fn fog_init() void = {
	glGenBuffers(1, &fog_ubo);
	glBindBufferBase(gl::GL_UNIFORM_BUFFER, UBO_BINDING_FOG, fog_ubo);
	glcheck()!;
};

// Current fog configuration.
export let fog_config = fog_params {
	factor = 1.0,
	near = 0.5,
	far = 256.0,
	color = [1.0, 1.0, 1.0],
};

// Applies the fog configuration.
export fn fog_apply() void = {
	glBindBuffer(gl::GL_UNIFORM_BUFFER, fog_ubo);
	glBufferData(gl::GL_UNIFORM_BUFFER,
		size(fog_params): uintptr,
		&fog_config,
		gl::GL_STATIC_DRAW);
};

// Disables fog.
export fn fog_disable() void = {
	fog_config.factor = 0.0;
	fog_apply();
};

// Enables fog.
export fn fog_enable() void = {
	fog_config.factor = 1.0;
	fog_apply();
};
