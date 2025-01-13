use fmt;
use gl;
use gl::{
	glAttachShader,
	glCompileShader,
	glCreateProgram,
	glCreateShader,
	glDeleteShader,
	glDetachShader,
	glGetProgramInfoLog,
	glGetProgramiv,
	glGetShaderInfoLog,
	glGetShaderiv,
	glGetUniformBlockIndex,
	glGetUniformLocation,
	glLinkProgram,
	glNamedStringARB,
	glShaderSource,
	glUniformBlockBinding,
	glUseProgram,
};
use io;
use os;
use path;
use strings;
use types::c;

const shader_lib = [
	"fog.glsl",
	"global.glsl",
	"lighting.glsl",
];

fn shaders_init() void = {
	let buf = path::init()!;
	for (let lib .. shader_lib) {
		path::set(&buf, "gfx", "glsl", "lib", lib)!;

		const file = os::open(path::string(&buf))!;
		defer io::close(file)!;
		const data = io::drain(file)!;
		defer free(data);

		path::set(&buf, "/", "lib", lib)!;
		const name = strings::toutf8(path::string(&buf));
		glNamedStringARB(gl::GL_SHADER_INCLUDE_ARB,
			len(name): i32, &name[0]: *i8,
			len(data): i32, &data[0]: *i8);
	};
};

// Loads a shader from the given vertex and fragment GLSL files as paths.
export fn shader_loadfrom(vert: str, frag: str) (uint | glerror) = {
	const file = os::open(vert)!;
	defer io::close(file)!;
	const data = io::drain(file)!;
	const vert = strings::fromutf8(data)!;
	defer free(vert);

	const file = os::open(frag)!;
	defer io::close(file)!;
	const data = io::drain(file)!;
	const frag = strings::fromutf8(data)!;
	defer free(frag);

	return shader_load(vert, frag)?;
};

// Loads a shader from the given vertex and fragment GLSL.
export fn shader_load(vert: str, frag: str) (uint | glerror) = {
	const vert_src = c::fromstr(vert);
	defer free(vert_src);

	const frag_src = c::fromstr(frag);
	defer free(frag_src);

	const vert_id = glCreateShader(gl::GL_VERTEX_SHADER);
	glShaderSource(vert_id, 1, &vert_src: *const nullable *const i8, null);
	glCompileShader(vert_id);

	let result = 0i32, log_length = 0i32;
	glGetShaderiv(vert_id, gl::GL_COMPILE_STATUS, &result);
	glGetShaderiv(vert_id, gl::GL_INFO_LOG_LENGTH, &log_length);
	if (log_length != 0) {
		let log: []i8 = alloc([0...], log_length: size)!;
		defer free(log);
		glGetShaderInfoLog(vert_id, log_length, null, &log[0]);
		fmt::fatalf("Error loading vertex: {}",
			strings::fromutf8(log: []u8)!);
	};

	const frag_id = glCreateShader(gl::GL_FRAGMENT_SHADER);
	glShaderSource(frag_id, 1, &frag_src: *const nullable *const i8, null);
	glCompileShader(frag_id);

	glGetShaderiv(frag_id, gl::GL_COMPILE_STATUS, &result);
	glGetShaderiv(frag_id, gl::GL_INFO_LOG_LENGTH, &log_length);
	if (log_length != 0) {
		let log: []i8 = alloc([0...], log_length: size)!;
		defer free(log);
		glGetShaderInfoLog(frag_id, log_length, null, &log[0]);
		fmt::fatalf("Error loading fragment: {}",
			strings::fromutf8(log: []u8)!);
	};

	const prog_id = glCreateProgram();
	glAttachShader(prog_id, vert_id);
	glAttachShader(prog_id, frag_id);
	glLinkProgram(prog_id);

	glGetProgramiv(prog_id, gl::GL_LINK_STATUS, &result);
	glGetProgramiv(prog_id, gl::GL_INFO_LOG_LENGTH, &log_length);
	if (log_length != 0) {
		let log: []i8 = alloc([0...], log_length: size)!;
		defer free(log);
		glGetProgramInfoLog(prog_id, log_length, null, &log[0]);
		fmt::fatalf("Error linking {}+{}: {}", vert, frag,
			strings::fromutf8(log: []u8)!);
	};

	glDetachShader(prog_id, vert_id);
	glDetachShader(prog_id, frag_id);
	glDeleteShader(vert_id);
	glDeleteShader(frag_id);

	glcheck()?;

	return prog_id;
};

def UBO_BINDING_FOG = 0;

// Binds a shader to the OpenGL context.
export fn shader_bind(id: uint) void = {
	// XXX: Ideally we wouldn't call this every time
	const fog_ubo = glGetUniformBlockIndex(id, c::nulstr("FogParams\0"): *i8);
	if (fog_ubo != gl::GL_INVALID_INDEX) {
		glUniformBlockBinding(id, fog_ubo, UBO_BINDING_FOG);
	};

	glUseProgram(id);
	glcheck()!;
};

// Populates a set of uniform locations associated with this shader. The strings
// must be nul terminated.
export fn shader_uniforms(id: uint, un: (str, *i32)...) void = {
	for (let u .. un) {
		*u.1 = glGetUniformLocation(id, c::nulstr(u.0): *i8);
	};
	glcheck()!;
};
