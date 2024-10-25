use fmt;
use gfx;
use gl;
use gl::{
	glActiveTexture,
	glBindBuffer,
	glBindTexture,
	glBlendFunc,
	glBufferData,
	glClear,
	glClearColor,
	glDisableVertexAttribArray,
	glDrawArrays,
	glEnable,
	glEnableVertexAttribArray,
	glGenBuffers,
	glGenTextures,
	glGetError,
	glGetUniformLocation,
	glTexImage2D,
	glTexParameteri,
	glUniformMatrix4fv,
	glUniform1i,
	glUseProgram,
	glVertexAttribPointer,
	glViewport,
};
use glm;
use sdl2;
use sdl2::{SDL_RendererFlags, SDL_WindowFlags, SDL_EventType, SDL_Scancode};
use sdl2::image;
use sdl2::mixer;
use types::c;

def WIN_WIDTH = 1280;
def WIN_HEIGHT = 720;
def SPEED: f32 = 1.0; // Meters per second
def HEIGHT: f32 = 1.85; // Meters

type movement = enum uint {
	LEFT		= 1 << 0,
	RIGHT		= 1 << 1,
	FORWARD		= 1 << 2,
	BACKWARD	= 1 << 3,
};

export fn main() void = {
	sdl2::SDL_Init(sdl2::SDL_INIT_VIDEO | sdl2::SDL_INIT_AUDIO)!;
	defer sdl2::SDL_Quit();

	image::IMG_Init(image::IMG_InitFlags::PNG)!;
	defer image::IMG_Quit();

	mixer::Mix_Init(mixer::MIX_InitFlags::OGG)!;
	defer mixer::Mix_Quit();

	mixer::Mix_OpenAudio(mixer::MIX_DEFAULT_FREQUENCY,
		mixer::MIX_DEFAULT_FORMAT,
		mixer::MIX_DEFAULT_CHANNELS,
		1024)!;
	defer mixer::Mix_CloseAudio();

	const win = sdl2::SDL_CreateWindow("betamine",
		sdl2::SDL_WINDOWPOS_UNDEFINED, sdl2::SDL_WINDOWPOS_UNDEFINED,
		WIN_WIDTH, WIN_HEIGHT, SDL_WindowFlags::OPENGL)!;
	defer sdl2::SDL_DestroyWindow(win);

	// TODO: Load via SDL_GL_GetProcAddress
	gl::load();

	const ctx = sdl2::SDL_GL_CreateContext(win);
	glViewport(0, 0, WIN_WIDTH, WIN_HEIGHT);
	glClearColor(0.2, 0.2, 0.2, 1.0);
	glEnable(gl::GL_DEPTH_TEST);
	glEnable(gl::GL_BLEND);
	//glEnable(gl::GL_CULL_FACE); // TODO: Fix cube model
	glBlendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);

	const terrain = gfx::load_terrain()!;

	let camera = gfx::camera_new(WIN_WIDTH: f32 / WIN_HEIGHT: f32);
	camera.pos = [1.0, 1.0 + HEIGHT, -4.0];
	gfx::camera_apply(&camera);

	// Prepare vertex buffer
	let vbuf = 0u;
	glGenBuffers(1, &vbuf);
	glBindBuffer(gl::GL_ARRAY_BUFFER, vbuf);
	glBufferData(gl::GL_ARRAY_BUFFER,
		(size(f32) * len(cube_verticies)): uintptr,
		&cube_verticies[0],
		gl::GL_STATIC_DRAW);
	assert(glGetError() == gl::GL_NO_ERROR);

	// Prepare UV buffer
	let uvbuf = 0u;
	glGenBuffers(1, &uvbuf);
	glBindBuffer(gl::GL_ARRAY_BUFFER, uvbuf);
	glBufferData(gl::GL_ARRAY_BUFFER,
		(size(f32) * len(cube_uv)): uintptr,
		&cube_uv[0],
		gl::GL_STATIC_DRAW);
	assert(glGetError() == gl::GL_NO_ERROR);

	// Prepare color buffer
	let colorbuf = 0u;
	glGenBuffers(1, &colorbuf);
	glBindBuffer(gl::GL_ARRAY_BUFFER, colorbuf);
	glBufferData(gl::GL_ARRAY_BUFFER,
		(size(f32) * len(cube_color)): uintptr,
		&cube_color[0],
		gl::GL_STATIC_DRAW);
	assert(glGetError() == gl::GL_NO_ERROR);

	let vp = glm::m4_new_zero();
	let mvp = glm::m4_new_zero();

	let quit = false;
	let move: movement = 0;
	let prev_ticks = 0u32;
	for (!quit) {
		let ev = sdl2::event { ... };
		for (sdl2::SDL_PollEvent(&ev)! == 1) {
			switch (ev.event_type) {
			case SDL_EventType::QUIT =>
				quit = true;
			case SDL_EventType::KEYDOWN =>
				switch (ev.key.keysym.scancode) {
				case SDL_Scancode::W =>
					move |= movement::FORWARD;
				case SDL_Scancode::S =>
					move |= movement::BACKWARD;
				case SDL_Scancode::A =>
					move |= movement::LEFT;
				case SDL_Scancode::D =>
					move |= movement::RIGHT;
				case => void;
				};
			case SDL_EventType::KEYUP =>
				switch (ev.key.keysym.scancode) {
				case SDL_Scancode::W =>
					move &= ~movement::FORWARD;
				case SDL_Scancode::S =>
					move &= ~movement::BACKWARD;
				case SDL_Scancode::A =>
					move &= ~movement::LEFT;
				case SDL_Scancode::D =>
					move &= ~movement::RIGHT;
				case => void;
				};
			case => void;
			};
		};

		glClear(gl::GL_COLOR_BUFFER_BIT | gl::GL_DEPTH_BUFFER_BIT);

		const ticks = sdl2::SDL_GetTicks();
		defer prev_ticks = ticks;
		const delta = ticks - prev_ticks;

		const forward: glm::v3 = [
			camera.dir[0] * delta: f32 / 100.0 * SPEED,
			camera.dir[1] * delta: f32 / 100.0 * SPEED,
			camera.dir[2] * delta: f32 / 100.0 * SPEED,
		];
		const right: glm::v3 = [
			camera.right[0] * delta: f32 / 100.0 * SPEED,
			camera.right[1] * delta: f32 / 100.0 * SPEED,
			camera.right[2] * delta: f32 / 100.0 * SPEED,
		];
		if (move & movement::FORWARD != 0) {
			camera.pos = glm::v3_add(&camera.pos, &forward);
		};
		if (move & movement::BACKWARD != 0) {
			camera.pos = glm::v3_sub(&camera.pos, &forward);
		};
		if (move & movement::LEFT != 0) {
			camera.pos = glm::v3_sub(&camera.pos, &right);
		};
		if (move & movement::RIGHT != 0) {
			camera.pos = glm::v3_add(&camera.pos, &right);
		};
		if (move != 0) {
			gfx::camera_apply(&camera);
		};

		let model = glm::m4_new_ident();
		glm::rotate(&model,
			ticks: f32 / 1000.0,
			&glm::v3_new(0.0, 1.0, 0.0));

		gfx::camera_matrix(&camera, &vp);
		glm::m4_mul_to(&vp, &model, &mvp);

		gfx::terrain_bind(&terrain, &mvp);

		// vertex buffer
		glEnableVertexAttribArray(0);
		glBindBuffer(gl::GL_ARRAY_BUFFER, vbuf);
		glVertexAttribPointer(0, 3, gl::GL_FLOAT, 0, 0, null);

		// uv buffer
		glEnableVertexAttribArray(1);
		glBindBuffer(gl::GL_ARRAY_BUFFER, uvbuf);
		glVertexAttribPointer(1, 2, gl::GL_FLOAT, 0, 0, null);

		// color buffer
		glEnableVertexAttribArray(2);
		glBindBuffer(gl::GL_ARRAY_BUFFER, colorbuf);
		glVertexAttribPointer(2, 3, gl::GL_FLOAT, 0, 0, null);

		glDrawArrays(gl::GL_TRIANGLES, 0, 12*3);

		glDisableVertexAttribArray(0);
		glDisableVertexAttribArray(1);

		sdl2::SDL_GL_SwapWindow(win);
		sdl2::SDL_Delay(1000 / 60);
	};
};
