use fmt;
use gl;
use gl::{
	glAttachShader,
	glCompileShader,
	glCreateProgram,
	glCreateShader,
	glDeleteShader,
	glDetachShader,
	glGetError,
	glGetProgramiv,
	glGetProgramInfoLog,
	glGetShaderInfoLog,
	glGetShaderiv,
	glLinkProgram,
	glShaderSource,
};
use io;
use os;
use strings;
use types::c;

// Returns the program ID.
fn load_shader(vert: str, frag: str) uint = {
	const file = os::open(vert)!;
	const vsrc = io::drain(file)!;
	defer free(vsrc);
	io::close(file)!;

	const vsrc = strings::fromutf8(vsrc)!;
	const vsrc = c::fromstr(vsrc);
	defer free(vsrc);

	const file = os::open(frag)!;
	const fsrc = io::drain(file)!;
	defer free(fsrc);
	io::close(file)!;

	const fsrc = strings::fromutf8(fsrc)!;
	const fsrc = c::fromstr(fsrc);
	defer free(fsrc);

	const vert_id = glCreateShader(gl::GL_VERTEX_SHADER);
	glShaderSource(vert_id, 1, &vsrc: *const nullable *const i8, null);
	glCompileShader(vert_id);

	let result = 0i32, log_length = 0i32;
	glGetShaderiv(vert_id, gl::GL_COMPILE_STATUS, &result);
	glGetShaderiv(vert_id, gl::GL_INFO_LOG_LENGTH, &log_length);
	if (log_length != 0) {
		let log: []i8 = alloc([0...], log_length: size);
		defer free(log);
		glGetShaderInfoLog(vert_id, log_length, null, &log[0]);
		fmt::fatalf("Error loading {}: {}", vert,
			strings::fromutf8(log: []u8)!);
	};

	const frag_id = glCreateShader(gl::GL_FRAGMENT_SHADER);
	glShaderSource(frag_id, 1, &fsrc: *const nullable *const i8, null);
	glCompileShader(frag_id);

	glGetShaderiv(frag_id, gl::GL_COMPILE_STATUS, &result);
	glGetShaderiv(frag_id, gl::GL_INFO_LOG_LENGTH, &log_length);
	if (log_length != 0) {
		let log: []i8 = alloc([0...], log_length: size);
		defer free(log);
		glGetShaderInfoLog(frag_id, log_length, null, &log[0]);
		fmt::fatalf("Error loading {}: {}", frag,
			strings::fromutf8(log: []u8)!);
	};

	const prog_id = glCreateProgram();
	glAttachShader(prog_id, vert_id);
	glAttachShader(prog_id, frag_id);
	glLinkProgram(prog_id);

	glGetProgramiv(prog_id, gl::GL_LINK_STATUS, &result);
	glGetProgramiv(prog_id, gl::GL_INFO_LOG_LENGTH, &log_length);
	if (log_length != 0) {
		let log: []i8 = alloc([0...], log_length: size);
		defer free(log);
		glGetProgramInfoLog(prog_id, log_length, null, &log[0]);
		fmt::fatalf("Error linking {}+{}: {}", vert, frag,
			strings::fromutf8(log: []u8)!);
	};

	glDetachShader(prog_id, vert_id);
	glDetachShader(prog_id, frag_id);
	glDeleteShader(vert_id);
	glDeleteShader(frag_id);

	assert(glGetError() == gl::GL_NO_ERROR);

	return prog_id;
};
