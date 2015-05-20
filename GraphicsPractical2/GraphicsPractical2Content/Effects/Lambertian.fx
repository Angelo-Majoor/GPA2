// Matrices for 3D perspective projection
float4x4 View, Projection, World;
// The inverse of the World matrix
float4x4 WorldInverse;
// The color of the object
float4 DiffuseColor;
// A source of light
float3 PointLight;

//float3x3 rotationAndScale = (float3x3) World;
// TODO: Apply the rotationAndScale to the normals
// TODO: Normalize them to remove any scaling

struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float3 Normal : NORMAL;
};

// What should come out of the vertex shader?
struct VertexShaderOutput
{
	float4 Position2D : POSITION0;
	float4 Color : COLOR0;
};

//-------------------------------- Technique: Lambertian ---------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
	float4 viewPosition = mul(worldPosition, View);
	output.Position2D = mul(viewPosition, Projection);

	// The normals might not be normalised
	input.Normal = normalize(input.Normal);

	// Determine the light vector
	// First get the light vector in object space
	vector objectLight = mul(PointLight, WorldInverse);
	vector lightDirection = normalize(objectLight - input.Position3D);

	// Diffuse using Lambert
	float Diffuse = max(0, dot(input.Normal, lightDirection));

	// Compute the final lighting
	output.Color = DiffuseColor * Diffuse;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	return input.Color;
}

technique Lambertian
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader = compile ps_2_0 SimplePixelShader();
	}
}