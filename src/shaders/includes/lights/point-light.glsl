vec3 pointLight(
    vec3 lightColor,
    float lightIntensity,
    vec3 normal,
    vec3 lightPosition,
    vec3 viewDirection,
    float specularPower,
    vec3 position,
    float lightDecay
) {
    vec3 lightDelta = lightPosition - position;
    float lightDistance = length(lightDelta);
    vec3 lightDirection = normalize(lightDelta);
    vec3 lightReflection = reflect(-lightDirection, normal);

    float shading = clamp(dot(normal, lightDirection), 0., 1.);
    float specular = pow(clamp(-dot(lightReflection, viewDirection), 0., 1.), specularPower);

    // Decay
    float decay = 1.0 - lightDistance * lightDecay;
    decay = max(0.0, decay);

    //return vec3(specular);
    return lightColor * lightIntensity * decay * (shading + specular);

}