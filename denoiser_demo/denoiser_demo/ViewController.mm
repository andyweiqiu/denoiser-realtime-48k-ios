//
//  ViewController.m
//  denoiser_demo
//
//  Created by 邱威 on 2022/9/6.
//

#import "ViewController.h"
#include "denoiser.h"
#define DR_WAV_IMPLEMENTATION
#include "dr_wav.h"

//read file
float *wavRead_scalar(const char *filename, unsigned int *sampleRate, drwav_uint64 *totalSampleCount) {
    unsigned int channels;
    float *buffer = drwav_open_file_and_read_pcm_frames_f32(filename, &channels, sampleRate,
                                                           totalSampleCount, NULL);
    if (buffer == nullptr) {
        printf("read wav file faild !");
    }
    
    if (channels != 1) {
        drwav_free(buffer, NULL);
        buffer = nullptr;
        *sampleRate = 0;
        *totalSampleCount = 0;
    }
    return buffer;
}

// write file
void wavWrite_scalar(const char* filename, float* buffer, size_t sampleRate, size_t totalSampleCount) {
    drwav_data_format format;
    format.container = drwav_container_riff;
    format.format = DR_WAVE_FORMAT_IEEE_FLOAT;
    format.channels = 1;
    format.sampleRate = (drwav_uint32)sampleRate;
    format.bitsPerSample = sizeof(float) * 8;
    // format.format = 0x3;
    drwav pWav;
    drwav_bool32 write_init = drwav_init_file_write(&pWav, filename, &format, NULL);

    if (write_init == 1) {
        drwav_uint64 framesWritten = drwav_write_pcm_frames(&pWav, totalSampleCount, buffer);
        drwav_uninit(&pWav);
        if (framesWritten != totalSampleCount) {
            fprintf(stderr, "ERROR\n");
            exit(1);
        }
    }
}

@interface ViewController ()

@end

@implementation ViewController
{
    void* denoiser_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    denoiser_ = NSCreate(48000);
}

- (IBAction)startButtonClicked:(id)sender {
    [self denoise];
}

- (void)denoise {
    NSString *wav_path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"wav"];
    const char* wav_file = [wav_path UTF8String];
    const char* out_file = [[self getWAVPath] UTF8String];
    
    unsigned int sampleRate = 0;
    drwav_uint64 totalSampleCount = 0;
    float *total_buffer = wavRead_scalar(wav_file, &sampleRate, &totalSampleCount);
    
    int audio_frame_size = 480;
    int frames = (int)totalSampleCount/480;
    float *audio_buffer = (float *)malloc(frames*audio_frame_size*sizeof(float));
    
    for (int i = 0; i < frames; i++) {
        float *in_buffer = total_buffer + i*audio_frame_size;
        float *out_buffer = audio_buffer + i*audio_frame_size;
        
        NSProcess(denoiser_, in_buffer, audio_frame_size, out_buffer);
    }
    
    // to wav
    wavWrite_scalar(out_file, audio_buffer, 48000, frames*audio_frame_size);
    free(total_buffer);
    free(audio_buffer);
    
    printf("Done ! \n");
}

- (NSString *)getWAVPath {
    NSString *directoryS = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *directory = [directoryS stringByAppendingPathComponent:@"enhanced.wav"];
    return directory;
}

@end
