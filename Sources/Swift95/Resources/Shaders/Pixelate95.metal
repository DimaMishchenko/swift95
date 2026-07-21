#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

[[ stitchable ]] half4 pixelate95(
  float2 position,
  SwiftUI::Layer layer,
  float4 bounds,
  float pixelSize
) {
  float2 localPosition = position - bounds.xy;
  float2 blockCenter =
    floor(localPosition / pixelSize) * pixelSize + pixelSize * 0.5;
  float2 minimumSample = bounds.xy + 0.5;
  float2 maximumSample = bounds.xy + bounds.zw - 0.5;
  float2 samplePosition = clamp(
    blockCenter + bounds.xy,
    minimumSample,
    maximumSample
  );

  return layer.sample(samplePosition);
}
