vec3 directionalLight(
    vec3 lightColor,
    float lightIntensity,
    vec3 normal,
    vec3 lightPosition,
    vec3 viewDirection,
    float specularPower
) {
    vec3 lightDirection = normalize(lightPosition);
    vec3 lightReflection = reflect(-lightDirection, normal);

    float shading = clamp(dot(normal, lightDirection), 0., 1.);
    float specular = pow(clamp(-dot(lightReflection, viewDirection), 0., 1.), specularPower);

    //return vec3(specular);
    return lightColor * lightIntensity * (shading + specular);

}