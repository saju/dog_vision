//
//  dog_vision.metal
//  DogVision
//
//  Created by Saju Pillai on 7/11/22.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;


extern "C" {
  namespace coreimage {

      /*
       * Dogs are dichromats. They can "see" yellow & blue, but can't see red.
       * To simulate dog's dichromat eyes, I set the green component of the pixel
       * to the same value as red -- because green + red = yellow. The blue component
       * and alpha values are unchanged.
       *
       * This is probably the most naive "dog vision" ever implemented.
       */
    float4 dog_eyes(sample_t in) {
        float4 out;
      
        out.g = in.r;
        out.r = in.r;
        out.b = in.b;
        out.a = in.a;
  
        return out;
    }
  }
}
