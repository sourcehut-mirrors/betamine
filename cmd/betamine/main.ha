use gl;
use gl::{
	glBindTexture,
	glClear,
	glClearColor,
	glGenTextures,
	glGetError,
	glTexImage2D,
	glTexParameteri,
	glViewport,
};
use sdl2;
use sdl2::{SDL_RendererFlags, SDL_WindowFlags, SDL_EventType};
use sdl2::image;
use sdl2::mixer;

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
		1280, 720, SDL_WindowFlags::OPENGL)!;
	defer sdl2::SDL_DestroyWindow(win);

	// TODO: Load via SDL_GL_GetProcAddress
	gl::load();

	const ctx = sdl2::SDL_GL_CreateContext(win);
	glViewport(0, 0, 1280, 720);
	glClearColor(1.0, 0.0, 0.0, 1.0);

	let terrainTexture = 0u;
	glGenTextures(1, &terrainTexture);
	glBindTexture(gl::GL_TEXTURE_2D, terrainTexture);

	const terrain = image::IMG_Load("assets/terrain.png")!;
	// TODO: Free surface
	glTexImage2D(gl::GL_TEXTURE_2D, 0, gl::GL_RGB: i32,
		terrain.w: i32, terrain.h: i32, 0,
		gl::GL_RGBA, gl::GL_UNSIGNED_BYTE,
		terrain.pixels);
	glTexParameteri(gl::GL_TEXTURE_2D,
		gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST: i32);
	glTexParameteri(gl::GL_TEXTURE_2D,
		gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST: i32);

	assert(glGetError() == gl::GL_NO_ERROR);

	const shader = load_shader("gfx/glsl/common.vert", "gfx/glsl/terrain.frag");

	let quit = false;
	for (!quit) {
		let ev = sdl2::event { ... };
		for (sdl2::SDL_PollEvent(&ev)! == 1) {
			if (ev.event_type == SDL_EventType::QUIT) {
				quit = true;
			};
		};

		glClear(gl::GL_COLOR_BUFFER_BIT);

		sdl2::SDL_GL_SwapWindow(win);
		sdl2::SDL_Delay(1000 / 60);
	};
};
