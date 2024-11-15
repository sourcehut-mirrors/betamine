use fmt;
use game;
use net::mc;
use sdl2;
use sdl2::{SDL_RendererFlags, SDL_WindowFlags, SDL_EventType, SDL_Scancode};
use sdl2::image;
use sdl2::mixer;

def WIN_WIDTH = 1280;
def WIN_HEIGHT = 720;
def FULLSCREEN = false;
def VSYNC = 0;

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

	let winflags = SDL_WindowFlags::OPENGL | SDL_WindowFlags::INPUT_GRABBED;
	if (FULLSCREEN) {
		winflags |= SDL_WindowFlags::FULLSCREEN;
	};

	const win = sdl2::SDL_CreateWindow("betamine",
		sdl2::SDL_WINDOWPOS_UNDEFINED, sdl2::SDL_WINDOWPOS_UNDEFINED,
		WIN_WIDTH, WIN_HEIGHT,
		winflags)!;
	defer sdl2::SDL_DestroyWindow(win);
	sdl2::SDL_SetRelativeMouseMode(true);

	const ctx = sdl2::SDL_GL_CreateContext(win);
	sdl2::SDL_GL_SetSwapInterval(VSYNC);

	let state = game::init(win);
	game::run(state);
	game::destroy(state);
};
