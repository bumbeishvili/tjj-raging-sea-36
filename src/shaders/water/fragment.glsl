// Uniforms for water color control
uniform vec3 uDepthColor;      // Color of the water at its deepest points
uniform vec3 uSurfaceColor;    // Color of the water at the surface
uniform float uColorOffset;    // Offset value to adjust the color mixing point
uniform float uColorMultiplier; // Multiplier to control the intensity of color mixing

// Varying values passed from vertex shader
varying float vElevation;      // Height of the vertex for color mixing
varying vec3 vNormal;          // Normal vector for lighting calculations
varying vec3 vPosition;        // Position in world space for view direction

// Import directional light calculations
#include ../includes/lights/directional-light.glsl
#include ../includes/lights/point-light.glsl

void main() {
    // Calculate view direction for lighting (from camera to fragment)
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    vec3 normal = normalize(vNormal);

    // Initialize lighting calculation
    vec3 light = vec3(0);

    // Add directional light contribution
    // light += directionalLight(
    //     vec3(1.0),              // Light color (white)
    //     1.0,                    // Light intensity
    //     normal,                 // Surface normal
    //     vec3(-1.0, 0.5, 0.0),  // Light direction
    //     viewDirection,          // View direction for specular
    //     30.0                    // Specular power (controls shininess)
    // );

    light += pointLight(
        vec3(1.0),              // Light color (white)
        20.0,                    // Light intensity
        normal,                 // Surface normal
        vec3(.0, 0.25, 0.0),  // Light direction
        viewDirection,          // View direction for specular
        30.0,                  // Specular power (controls shininess)
        vPosition, 0.95
    );

    // Calculate color mixing based on elevation
    float mixStrength = (vElevation + uColorOffset) * uColorMultiplier;
    // Smooth step to create a more natural transition between colors
    mixStrength = smoothstep(0.0, 1.0, mixStrength);
    // Mix between depth and surface colors based on elevation
    vec3 color = mix(uDepthColor, uSurfaceColor, mixStrength);
    // Apply lighting to the final color
    color *= light;

    // Output final color with normal visualization (for debugging)
    gl_FragColor = vec4(color, 1.0);

    // Apply tone mapping and color space conversion
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}