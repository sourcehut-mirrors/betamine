// An NBT tag.
export type nbt_tag = enum u8 {
	END,
	BYTE,
	SHORT,
	INT,
	LONG,
	FLOAT,
	DOUBLE,
	BYTE_ARRAY,
	STRING,
	LIST,
	COMPOUND,
};

// An NBT value.
export type value = struct {
	// Only present if a member of a compound tag, otherwise ""
	name: str,

	tag: nbt_tag,
	union {
		_i8: i8,
		_i16: i16,
		_i32: i32,
		_i64: i64,
		_f32: f32,
		_f64: f64,

		// Valid for BYTE_ARRAY or STRING
		length: u32,

		// Valid for LIST
		list: struct {
			tag: nbt_tag,
			length: u32,
		},
	},
};
