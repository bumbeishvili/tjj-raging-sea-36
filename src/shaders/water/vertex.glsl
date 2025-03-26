// Import required shader functions
#include ../includes/perlinClassic3D.glsl
#include ../includes/lights/point-light.glsl
#include ../includes/lights/directional-light.glsl

// Uniforms for animation and wave control
uniform float uTime;               // Time for animation
// Big waves parameters
uniform float uBigWavesElevation; // Height of the large waves
uniform vec2 uBigWavesFrequency;  // Frequency of large waves in x and z directions
uniform float uBigWavesSpeed;     // Speed of large wave movement

// Small waves parameters
uniform float uSmallWavesElevation;  // Height of the small waves
uniform float uSmallWavesFrequency;  // Frequency of small waves
uniform float uSmallWavesSpeed;      // Speed of small wave movement
uniform float uSmallIterations;      // Number of iterations for small wave detail

// Varyings passed to fragment shader
varying float vElevation;  // Final vertex elevation for color mixing
varying vec3 vNormal;      // Normal vector for lighting
varying vec3 vPosition;    // Position for view calculations

float waveElevation(vec3 position) {
       // Calculate base elevation using sine waves for large wave motion
    float elevation = sin(position.x * uBigWavesFrequency.x + uTime * uBigWavesSpeed) *
        sin(position.z * uBigWavesFrequency.y + uTime * uBigWavesSpeed) *
        uBigWavesElevation;

    // Add detail to waves using Perlin noise
    for(float i = 1.0; i <= uSmallIterations; i++) {
        // Each iteration adds smaller, more detailed waves
        elevation -= abs(perlinClassic3D(vec3(position.xz * uSmallWavesFrequency * i, uTime * uSmallWavesSpeed)) * uSmallWavesElevation / i);
    }
    return elevation;
}
// Classic Perlin 3D Noise 
// by Stefan Gustavson
//
void main() {
    float shift = 0.01;// how far are neighbours 

    // Transform vertex position to world space
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);

    vec3 modelPositionA = modelPosition.xyz + vec3(shift, 0.0, 0.0);
    vec3 modelPositionB = modelPosition.xyz + vec3(0.0, 0.0, -shift);

    float elevation = waveElevation(modelPosition.xyz);
     modelPosition.y += elevation;
    modelPositionA.y += waveElevation(modelPositionA);
    modelPositionB.y += waveElevation(modelPositionB);

    vec3 toA = normalize(modelPositionA - modelPosition.xyz);
    vec3 toB = normalize(modelPositionB - modelPosition.xyz);
    vec3 computedNormal = cross(toA, toB);

    // Apply calculated elevation to vertex
   

    // Transform position to clip space
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    // Pass values to fragment shader
    vElevation = elevation;
    vNormal =computedNormal;  // Transform normal to world space
    vPosition = modelPosition.xyz;                     // Pass world position
}