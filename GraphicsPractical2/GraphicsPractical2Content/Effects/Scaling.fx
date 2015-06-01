//------------------------------------- Top Level Variables -------------------------------------

// Matrices for 3D perspective projection
float4x4 View, Projection, World;
// The inverse of the World matrix
float4x4 WorldInverse;
// The inverse transposed of the World matrix
float4x4 WorldInverseTransposed;

// The diffuse color for the object
float4 DiffuseColor;

// The ambient color for the object
float4 AmbientColor;
// The ambient intensity for the object
float AmbientIntensity;

// A source of light
float3 PointLight;

// The cameras eye position
float3 CameraPosition;

// The specular color of the Blinn Phong shading
float4 SpecularColor;
// The specular intensity of the Blinn Phong shading
float SpecularIntensity;
// The specular power of the Blinn Phong shading
float SpecularPower;

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
	float4 Specular : TEXCOORD1;
	float4 Diffuse : TEXCOORD2;
};

//-------------------------------- Technique: Scaling ---------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
	float4 viewPosition = mul(worldPosition, View);
	output.Position2D = mul(viewPosition, Projection);

	// Apply the inverse transposed matrix to the normals
	float3 intermediateNormal = mul(WorldInverseTransposed, input.Normal);
	// Normalize the normals
	input.Normal = normalize(intermediateNormal);

	// Determine the light vector
	// First get the light vector in object space
	vector objectLight = mul(PointLight, WorldInverse);
	vector lightDirection = normalize(objectLight - input.Position3D);

	// Determine the eye vector
	// First get the eye vector in object space
	vector objectEye = mul(CameraPosition, WorldInverse);
	vector eyeDirection = normalize(objectEye - input.Position3D);

	// Compute the half vector
	vector halfVector = normalize((lightDirection + eyeDirection) / 2);

	// Specular using Blinn Phong
	output.Specular = max(0, pow(dot(input.Normal, halfVector), SpecularPower));

	// Diffuse using Lambert
	output.Diffuse = max(0, dot(input.Normal, lightDirection));

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	// Compute the final lighting
	return ((DiffuseColor * input.Diffuse) + (AmbientColor * AmbientIntensity) + (SpecularColor * SpecularIntensity * input.Specular));
}

technique Scaling
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader = compile ps_2_0 SimplePixelShader();
	}
}