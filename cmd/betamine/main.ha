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
use sdl3;
use sdl3::image;
use sdl3::{InitFlags, WindowFlags};
use types::c;

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

	sdl3::Init(InitFlags::VIDEO)!;
	defer sdl3::Quit();

	let winflags = WindowFlags::OPENGL | WindowFlags::MOUSE_GRABBED;
	if (fullscreen) {
		winflags |= WindowFlags::FULLSCREEN;
	};

	const win = sdl3::CreateWindow(c::nulstr("betamine\0"),
		WIN_WIDTH, WIN_HEIGHT, winflags)!;
	defer sdl3::DestroyWindow(win);
	sdl3::SetWindowRelativeMouseMode(win, true)!;

	const ctx = sdl3::GL_CreateContext(win);
	sdl3::GL_SetSwapInterval(VSYNC)!;

	let state = game::init(win, &conn, &login, username);
	state.debug = debug;
	if (flying) {
		state.player.flags |= entity_flag::FLYING;
		state.player.speed *= 2.0;
	};

	game::run(state);
	game::destroy(state);
};
