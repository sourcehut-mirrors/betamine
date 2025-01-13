use encoding::ucs2;
use engine::{entity_flag};
use fmt;
use game;
use getopt;
use io;
use log;
use net::dial;
use net::mc;
use os;
use sdl2;
use sdl2::{SDL_RendererFlags, SDL_WindowFlags, SDL_EventType, SDL_Scancode};
use sdl2::image;
use sdl2::mixer;

def WIN_WIDTH = 1280;
def WIN_HEIGHT = 720;
def VSYNC = 0;

export fn main() void = {
	const usage: []getopt::help = [
		"betamine client",
		('u', "username", "set client username"),
		('d', "enable debug overlay at startup"),
		('f', "set fullscreen"),
		('F', "enable flying"),
		"hostname[:port]",
	];
	const cmd = getopt::parse(os::args, usage...);
	defer getopt::finish(&cmd);

	if (len(cmd.args) == 0) {
		getopt::printusage(os::stderr, os::args[0], usage)!;
		os::exit(1);
	};

	let username = "betamine";
	let fullscreen = false, debug = false, flying = false;
	for (const (opt, val) .. cmd.opts) {
		switch (opt) {
		case 'd' => debug = true;
		case 'f' => fullscreen = true;
		case 'F' => flying = true;
		case 'u' => username = val;
		case => abort();
		};
	};

	const conn = match (mc::dial(cmd.args[0])) {
	case let err: dial::error =>
		fmt::fatal(dial::strerror(err));
	case let c: mc::conn =>
		yield c;
	};

	const login = match (mc::login(&conn, username)) {
	case let login: mc::login_request =>
		yield login;
	case let dc: mc::disconnect_packet =>
		const reason = ucs2::fromucs2(dc.reason)!;
		defer free(reason);
		mc::close(&conn);
		log::fatal(reason);
	case let err: io::error =>
		mc::close(&conn);
		log::fatal(io::strerror(err));
	};
	defer mc::disconnect(&conn, "Player quit");

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
	if (fullscreen) {
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

	let state = game::init(win, &conn, &login, username);
	state.debug = debug;
	if (flying) {
		state.player.flags |= entity_flag::FLYING;
		state.player.speed *= 2.0;
	};

	game::run(state);
	game::destroy(state);
};
