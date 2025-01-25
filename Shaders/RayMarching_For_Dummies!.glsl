// https://www.youtube.com/watch?v=PGtv-dBi2wE&t=139s
// 1. Ray Marching 架构
// 2. 球体及平面的SDF距离场函数
// 3. 硬阴影的实现
// 4. 简单的着色模型(diffuse)

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .01

float sdSphere( vec3 p, float r ){
 	return length(p) - r;   
}

float GetDist( vec3 p ){
    vec4 s = vec4(0, 1, 6, 1); // position -> (0, 1, 6) radius -> 1
    float ds = sdSphere(p - s.xyz, s.w);
    float dp = p.y;
    
    float d = min(ds, dp);
    return d;
}

vec3 GetNormal( vec3 p ){
    float d = GetDist(p);
    vec2 e = vec2(.01, 0);

    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));
    return normalize(n);
}

float RayMarch( vec3 ro, vec3 rd ){
    float dt = 0.;

    for(int i=0;i<MAX_STEPS;i++)
    {
        vec3 p = ro + rd*dt;
        float ds = GetDist(p);
        dt += ds;
        if(dt>MAX_DIST||ds<SURF_DIST) break;
    }

    return dt;
}

float GetLighting( vec3 p ){
    vec3 lightPos = vec3(0,5,6);
    lightPos.xz += vec2(sin(iTime), cos(iTime))*2.;
    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p);
    
    float diff = clamp(dot(n, l), 0., 1.);
    float d = RayMarch(p+n*SURF_DIST*2.0, l);
    if(d<length(lightPos-p)) diff *= 0.1;

    return diff;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;  // ratio
    vec3 col = vec3(0);

    vec3 ro = vec3(0, 1, 0);
    vec3 rd = normalize(vec3(uv.x, uv.y, 1.0));

    float d = RayMarch(ro, rd);
    vec3 p = ro+rd*d;
    float diff = GetLighting(p);

    // col = vec3(d/6.0);
    // col  = vec3(GetNormal(p));
    col = vec3(diff);
    col = pow(col, vec3(.4545)); // gamma correction

    // Output to screen
    fragColor = vec4(col,1.0);
}