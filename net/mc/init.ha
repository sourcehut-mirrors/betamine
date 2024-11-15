use net::dial;

// Minecraft protocol version (for beta 1.7.3)
export def VERSION: int = 14;

@init fn init() void = {
	dial::registersvc("tcp", "minecraft", [], 25565);
};
