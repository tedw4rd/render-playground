//Shamelessly borrowed from https://docs.unity3d.com/Packages/com.unity.shadergraph@6.7/manual/Voronoi-Node.html
inline float2 unity_voronoi_noise_randomVector(float2 UV, float offset)
{
	float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
	UV = frac(sin(mul(UV, m)) * 46839.32);
	return float2(sin(UV.y*+offset)*0.5 + 0.5, cos(UV.x*offset)*0.5 + 0.5);
}

void VoronoiTessellation_float(float2 UV, float AngleOffset, float GridSize, out float2 Output)
{
	float2 s = UV * GridSize;
	float2 g = floor(s);
	float2 f = frac(s);
	float t = 8.0;
	float3 res = float3(8.0, 0.0, 0.0);

	for (int y = -1; y <= 1; y++)
	{
		for (int x = -1; x <= 1; x++)
		{
			float2 lattice = float2(x, y);
			float2 offset = unity_voronoi_noise_randomVector(lattice + g, AngleOffset);
			float d = distance(lattice + offset, f);
			if (d < res.x)
			{
				res = float3(d, offset.x, offset.y);
				Output = (lattice + g) / GridSize;
			}
		}
	}
}

void SquareTessellation_float(float2 UV, float GridSize, out float2 Output)
{
	float2 s = UV * GridSize;
	float2 g = floor(s);
	Output = g / GridSize;
}

inline float2x2 rotation_matrix2x2(float d)
{
	float s = sin(radians(d));
	float c = cos(radians(d));
	return float2x2(c, -s, s, c);
}

void EquilateralTriangleTessellation_float(float2 UV, float GridSize, out float2 Output)
{
	UV = UV * GridSize;

	float h = mul(UV, rotation_matrix2x2(60)).y;
	float x = mul(UV, rotation_matrix2x2(-60)).y;

	x = (floor(x) - floor(h)) / 2;

	Output = float2(x, floor(UV.y));

	float2x2 s = float2x2(1. / cos(radians(30)), 0, 0, 1.);
	Output = mul(s, Output) / GridSize;
}

void HexagonTessellation_float(float2 UV, float GridSize, out float2 Output)
{
	float2x2 b = { 2. / 3, 0, -1. / 3, sqrt(3) / -3. };

	UV = UV * GridSize * sqrt(3);
	float2 axial = mul(b, UV);
	float3 cube = float3(axial.x, -axial.x - axial.y, axial.y);

	float3 err = abs(round(cube) - cube);
	err = step(0, err - max(err.x, max(err.y, err.z)));
	float3 cubeMask = 1 - err;

	float3 roundedCube = (round(cube) * cubeMask) + (err * dot(round(cube), -cubeMask));

	float3x3 t = float3x3(1, 0, 0, 0, 0, -1, 0, 0, 0);

	float3x3 s = float3x3(sqrt(3) / 6, 0, 0, -1. / 6, 1. / 3, 0, 0, 0, 0);

	Output = mul(s, mul(t, roundedCube)) / (GridSize/3.);
}