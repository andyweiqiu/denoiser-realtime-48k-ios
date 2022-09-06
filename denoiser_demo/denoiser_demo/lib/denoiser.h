//
//  denoiser.h
//  denoiser
//
//  Created by 邱威 on 2022/9/6.
//

#ifndef denoiser_h
#define denoiser_h

#include <stdio.h>

#endif /* denoiser_h */


void* NSCreate(int sample_rate);
void NSProcess(void* denoiser, float* audio_in, int frame_size, float* audio_out);
void NSDestroy(void* denoiser);
