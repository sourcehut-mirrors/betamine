use fmt;
use gl;
use gl::{
	glActiveTexture,
	glBindBuffer,
	glBindTexture,
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
use sdl2::{SDL_RendererFlags, SDL_WindowFlags, SDL_EventType};
use sdl2::image;
use sdl2::mixer;
use types::c;

def WIDTH = 1280;
def HEIGHT = 720;

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
		WIDTH, HEIGHT, SDL_WindowFlags::OPENGL)!;
	defer sdl2::SDL_DestroyWindow(win);

	// TODO: Load via SDL_GL_GetProcAddress
	gl::load();

	const ctx = sdl2::SDL_GL_CreateContext(win);
	glViewport(0, 0, WIDTH, HEIGHT);
	glClearColor(0.2, 0.2, 0.2, 1.0);
	glEnable(gl::GL_DEPTH_TEST);

	let terrainTexture = 0u;
	glGenTextures(1, &terrainTexture);
	glBindTexture(gl::GL_TEXTURE_2D, terrainTexture);

	const terrain = image::IMG_Load("assets/terrain.png")!;
	fmt::println(sdl2::SDL_GetPixelFormatName(terrain.format.format))!;

	// TODO: Free surface
	glTexImage2D(gl::GL_TEXTURE_2D, 0,
		gl::GL_BGRA: i32,
		terrain.w: i32, terrain.h: i32, 0,
		gl::GL_RGBA, gl::GL_UNSIGNED_BYTE,
		terrain.pixels);
	assert(glGetError() == gl::GL_NO_ERROR);

	glTexParameteri(gl::GL_TEXTURE_2D,
		gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST: i32);
	glTexParameteri(gl::GL_TEXTURE_2D,
		gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST: i32);

	const shader = load_shader("gfx/glsl/common.vert", "gfx/glsl/terrain.frag");

	const umvp = glGetUniformLocation(shader, c::nulstr("mvp\0"): *i8);
	const utex = glGetUniformLocation(shader, c::nulstr("tex\0"): *i8);

	let proj = glm::m4_new_zero();
	glm::perspective(&proj, 45.0, WIDTH: f32 / HEIGHT: f32, 0.1, 100.0);

	let view = glm::lookat(
		&glm::v3_new(4.0, 3.0, 3.0),
		&glm::v3_new(0.0, 0.0, 0.0),
		&glm::v3_new(0.0, 1.0, 0.0),
	);

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

	let quit = false;
	for (!quit) {
		let ev = sdl2::event { ... };
		for (sdl2::SDL_PollEvent(&ev)! == 1) {
			if (ev.event_type == SDL_EventType::QUIT) {
				quit = true;
			};
		};

		glClear(gl::GL_COLOR_BUFFER_BIT | gl::GL_DEPTH_BUFFER_BIT);

		glUseProgram(shader);

		let model = glm::m4_new_ident();
		let ticks = sdl2::SDL_GetTicks();
		glm::rotate(&model,
			ticks: f32 / 1000.0,
			&glm::v3_new(0.0, 1.0, 0.0));
		let mvp = glm::m4_mul(&proj, &view);
		mvp = glm::m4_mul(&mvp, &model);

		// Uniforms
		glUniformMatrix4fv(umvp, 1, 0, &mvp[0][0]);
		assert(glGetError() == gl::GL_NO_ERROR);

		glActiveTexture(gl::GL_TEXTURE0);
		glBindTexture(gl::GL_TEXTURE_2D, terrainTexture);
		glUniform1i(utex, 0);
		assert(glGetError() == gl::GL_NO_ERROR);

		// vertex buffer
		glEnableVertexAttribArray(0);
		glBindBuffer(gl::GL_ARRAY_BUFFER, vbuf);
		glVertexAttribPointer(0, 3, gl::GL_FLOAT, 0, 0, null);
		assert(glGetError() == gl::GL_NO_ERROR);

		// uv buffer
		glEnableVertexAttribArray(1);
		glBindBuffer(gl::GL_ARRAY_BUFFER, uvbuf);
		glVertexAttribPointer(1, 2, gl::GL_FLOAT, 0, 0, null);
		assert(glGetError() == gl::GL_NO_ERROR);

		glDrawArrays(gl::GL_TRIANGLES, 0, 12*3);
		assert(glGetError() == gl::GL_NO_ERROR);

		glDisableVertexAttribArray(0);
		glDisableVertexAttribArray(1);

		sdl2::SDL_GL_SwapWindow(win);
		sdl2::SDL_Delay(1000 / 60);
	};
};
