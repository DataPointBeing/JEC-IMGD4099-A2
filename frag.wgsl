@group(0) @binding(0) var<uniform> t: f32;
@group(0) @binding(1) var<uniform> res: vec2f;
@group(0) @binding(2) var<uniform> mse: vec3f;

@group(0) @binding(3) var<uniform> steps: f32;
@group(0) @binding(4) var<uniform> depth: f32;
@group(0) @binding(5) var<uniform> lightDirection: f32;
@group(0) @binding(6) var<uniform> brightness: f32;
@group(0) @binding(7) var<uniform> contrast: f32;

@group(0) @binding(8) var backSampler: sampler;
@group(0) @binding(9) var backBuffer: texture_2d<f32>;
@group(0) @binding(10) var videoSampler: sampler;
@group(1) @binding(0) var videoBuffer: texture_external;

@fragment
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  let p = pos.xy / res;

  let video = textureSampleBaseClampToEdge(videoBuffer, videoSampler, p);

  // let fb = textureSample( backBuffer, backSampler, p );

  let thisColor = (floor(video * steps) / steps).xyz;

  let shadowP = p + vec2(depth * cos(6.28319 * lightDirection), depth * sin(6.28319 * lightDirection));

  let offsetVideo = textureSampleBaseClampToEdge(videoBuffer, videoSampler, shadowP).xyz;

  let offsetColor = (floor(offsetVideo * steps) / steps).xyz;

  let thisTotal = thisColor.x + thisColor.y + thisColor.z;
  let offsetTotal = offsetColor.x + offsetColor.y + offsetColor.z;

  var modifiedColor : vec3f = ((contrast * (thisColor - 0.5)) + 0.5) + brightness;
  var modifiedOffsetColor : vec3f = ((contrast * (offsetColor - 0.5)) + 0.5) + brightness;

  var out : vec3f = modifiedColor * modifiedOffsetColor * modifiedOffsetColor * 0.5;

  if(offsetTotal < thisTotal) {
    out = modifiedColor;
  }
  else if (offsetTotal == thisTotal) {
    if(offsetColor.x < thisColor.x || (offsetColor.x == thisColor.x && offsetColor.y < thisColor.y)) {
      out = modifiedColor;
    }
    else if(offsetColor.x == thisColor.x && offsetColor.y == thisColor.y && offsetColor.z == thisColor.z) {
      out = modifiedColor;
    }
  }

  let noise = fract(sin(vec2(dot((p + (thisColor.x * 100) + (thisColor.y * 10) + thisColor.z), vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453) * 0.1;
  out = vec3f(out.xy - noise.xy, out.z - noise.x);


  return vec4f(out, 1. );
}