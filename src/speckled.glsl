varying vec2 vUv;
uniform float uTime;

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}
vec2 rotateUV(vec2 uv, float rotation, vec2 mid)
{
    return vec2(
      cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x,
      cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y
    );
}

void main(){
    // vec3 color = vec3(1.);

    // scale & tile
    // vec2 uv = vUv * vec2(10., 10.);
    // vec2 intUv = floor(uv);
    // vec2 floatUv = fract(uv);

    // float minDistance = 1.;

    // loop through cells
    // (pixel-based voronoi pattern)
    // for(int y = -1; y <= 1; y++){
    //     for (int x = -1; x <= 1; x++){
    //         vec2 neighborOffset = vec2(x, y);
    //         vec2 point = random2(intUv + neighborOffset);
    //         // point = vec2(0.5 + 0.5 * sin(uTime * 0.8 + 3.1283 * point.x), 0.5 + 0.5 * sin(uTime * 0.7 + 58.123 * point.y));
    //         point = vec2(0.5 + 0.5 * sin(3.1283 * point.x), 0.5 + 0.5 * sin(58.123 * point.y));
    //         vec2 diff = neighborOffset + point - floatUv;
    //         minDistance = min(minDistance, length(diff));
    //     }
    // }

    // loop through points
    // (point-based voronoi)
    vec3 color = vec3(1.);

    // Cell points
    const int pointCount = 100;
    float minDistance = 1.;
    vec2 closestPointPosition;

    vec2 point[pointCount];

    for (int i = 0; i < pointCount; i++){
        point[i] = random2(vec2(i));

        float dist = distance(vUv, point[i]);
        if (dist < minDistance){
            minDistance = dist;
            closestPointPosition = point[i];
        }
    }

    // a random float between 0-1 acting as this cell's "ID"
    float pointId = random2(closestPointPosition).r;

    // rotate UV around cell point
    vec2 rotUv = rotateUV(vUv, sin(pointId), closestPointPosition);
    // vec2 rotatedAndTiled = rotUv * 2.;
    // vec2 intTile = floor(rotatedAndTiled);


    // color.rgb = vec3(rotUv.y);

    color.rgb = mix(color.rgb, 1. - vec3(step(0.9, fract(rotUv.g * 100.))), step(0.9, pointId));
    // color.rgb = 1. - vec3(pow(distance(vUv, closestPointPosition) * 10., 50.));
    // color.rgb *= 1. - distance(closestPointPosition, vUv) * 8.;
    // color.rgb *= step(0.9, color.rgb);
    // color.rgb = 1. - color.rgb;
    
    

    // color *= minDistance;

    gl_FragColor = vec4(color, 1.);
}