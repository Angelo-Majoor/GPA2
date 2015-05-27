//------------------------------------- Top Level Variables -------------------------------------

// Matrices for 3D perspective projection
float4x4 View, Projection, World;
// The inverse of the World matrix
float4x4 WorldInverse;

// The diffuse color for the object
float4 DiffuseColor;

// A source of light
float3 PointLight;

//---------------------------------- Input / Output structures ----------------------------------

// The input of the vertex shader
struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float3 Normal : NORMAL;
};

// The output of the vertex shader
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

	// To do correct lighting calculations using the normals, take the World matrix into
	// account. If the model gets rotated, so must the normals. One way to do this is 
	// extract the top left 3x3 matrix out of the World matrix, which holds the rotation 
	// and scaling part of the World transformation, apply that to the normals and 
	// finally normalize them so that any scaling is removed.
	// 
	// Extract the top-left 3x3 matrix out of the World matrix
	float3x3 rotationAndScale = (float3x3) World;
	// Apply this matrix to the normals
	float3 intermediateNormal = mul(rotationAndScale, input.Normal);
	// Normalize the normals
	input.Normal = normalize(intermediateNormal);

	// Determine the light vector
	// First get the light vector in object space
	vector objectLight = mul(PointLight, WorldInverse);
	vector lightDirection = normalize(objectLight - input.Position3D);

	// Diffuse using Lambert
	float diffuse = max(0, dot(input.Normal, lightDirection));

	// Compute the final lighting
	output.Color = DiffuseColor * diffuse;

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