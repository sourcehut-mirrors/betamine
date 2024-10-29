#define DAY_TICKS 24000
#define M_PI 3.14159265358979323846
#define M_2PI 2 * M_PI

layout (std140) uniform GlobalParams {
	// Complete model-view-projection matrix
	uniform mat4 MVP;
	// Current time in ticks modulo 24000 (day cycle)
	uint Ticks;
};

float celestialAngle() {
	float x = clamp(Ticks / 24000.0 - 0.25, 0.0, 1.0);
	return x + ((1.0 - (cos(x * M_PI) + 1.0) / 2.0) - x) / 3.0;
}
