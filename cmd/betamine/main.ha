use engine;
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
use math;
use sdl2;
use sdl2::{SDL_RendererFlags, SDL_WindowFlags, SDL_EventType, SDL_Scancode};
use sdl2::image;
use sdl2::mixer;
use types::c;

def WIN_WIDTH = 1280;
def WIN_HEIGHT = 720;
def SPEED: f32 = 4.317; // Meters per second
def MOUSE_SPEED: f32 = 2.0;
def HEIGHT: f32 = 1.85; // Player height in meters

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
		WIN_WIDTH, WIN_HEIGHT,
		SDL_WindowFlags::OPENGL | SDL_WindowFlags::INPUT_GRABBED)!;
	defer sdl2::SDL_DestroyWindow(win);
	sdl2::SDL_SetRelativeMouseMode(true);

	const ctx = sdl2::SDL_GL_CreateContext(win);
	sdl2::SDL_GL_SetSwapInterval(1);
	gfx::init(WIN_WIDTH, WIN_HEIGHT);

	const terrain = gfx::load_terrain()!;
	let camera = gfx::camera_new();
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

	let vp = glm::M4_ZERO;
	let mvp = glm::M4_ZERO;

	let quit = false;
	let move: movement = 0;
	let prev_time = 0u32;
	let frames = 0u64, ticks = 0u64;
	let fps = 0u, nframe = 0u;
	for (!quit; frames += 1) {
		let mx = 0i32, my = 0i32;
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
			case SDL_EventType::MOUSEMOTION =>
				mx = ev.motion.xrel;
				my = ev.motion.yrel;
			case => void;
			};
		};

		if (frames % 3 == 0) {
			ticks += 1;
		};

		const time = sdl2::SDL_GetTicks();
		defer prev_time = time;
		const delta = (time - prev_time): f32 / 1000.0;
		if (prev_time / 1000 != time / 1000) {
			fps = nframe;
			nframe = 0;
		};
		defer nframe += 1;

		const forward: glm::v3 = [
			math::sinf64(camera.yaw): f32 * delta * SPEED,
			0.0,
			math::cosf64(camera.yaw): f32 * delta * SPEED,
		];
		const right: glm::v3 = [
			camera.right[0] * delta * SPEED,
			0.0,
			camera.right[2] * delta * SPEED,
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

		camera.yaw += MOUSE_SPEED * delta * -mx: f32;
		camera.pitch += MOUSE_SPEED * delta * -my: f32;

		def PITCH_MIN = -(math::PI / 2.0): f32;
		def PITCH_MAX = (math::PI / 2.0): f32;
		if (camera.pitch < PITCH_MIN) camera.pitch = PITCH_MIN;
		if (camera.pitch > PITCH_MAX) camera.pitch = PITCH_MAX;

		if (move != 0 || mx != 0 || my != 0) {
			gfx::camera_apply(&camera);
		};

		gfx::camera_matrix(&camera, &vp);
		gfx::render_sky(&camera, ticks);

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

		let model = glm::M4_IDENT;
		for (let x = -8; x < 8; x += 1)
		for (let z = -8; z < 8; z += 1) {
			model = glm::M4_IDENT;
			glm::translate(&model, &glm::v3_new(x: f32, 0.0, z: f32));

			glm::m4_mul_to(&vp, &model, &mvp);
			gfx::terrain_bind(&terrain, &mvp);
			glDrawArrays(gl::GL_TRIANGLES, 0, 12*3);
		};

		glDisableVertexAttribArray(0);
		glDisableVertexAttribArray(1);

		static let buf: [512]u8 = [0...];
		const pos = fmt::bsprintf(buf, "x: {}\ny: {}\nz: {}",
			camera.pos[0],
			camera.pos[1],
			camera.pos[2]);

		gfx::font_draw(&glm::v2_new(0.0, 0.0 * 24.0), "Betamine 0.0.0");
		gfx::font_draw(&glm::v2_new(0.0, 1.0 * 24.0), pos);

		const dir = engine::radtocard(camera.yaw);
		const look = fmt::bsprintf(buf, "  look: {}\n   yaw: {}\npitch: {}",
			engine::cardtostr(dir),
			camera.pitch, camera.yaw);
		gfx::font_draw(&glm::v2_new(256.0, 1.0 * 24.0), look);

		const fps = fmt::bsprintf(buf, "FPS: {}", fps);
		const (fw, _) = gfx::font_measure(fps);
		gfx::font_draw(&glm::v2_new((WIN_WIDTH - fw): f32, 0.0), fps);

		sdl2::SDL_GL_SwapWindow(win);
	};
};
