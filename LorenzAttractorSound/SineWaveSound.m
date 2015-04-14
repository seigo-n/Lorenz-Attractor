//
//  SineWaveSound.m
//  LorenzAttractorSound
//
//  Created by NSNSN on 2015/04/12.
//

#import "SineWaveSound.h"

@interface SineWaveSound()
@property(nonatomic) AudioUnit audioUnit;
@property(nonatomic) BOOL isPlaying;
@end

@implementation SineWaveSound

double _generatingFreq;
double _volume;

- (id)init {
    self = [super init];
    if (self != nil){
        _generatingFreq = 440.0;
        self.phase = 0.0;
        _volume = 1.0;
        [self prepareAudioUnit];
    }
    
    return self;
}
- (void)dealloc {
    [self stop];
    AudioUnitUninitialize(_audioUnit);
    AudioComponentInstanceDispose(_audioUnit);
}

- (void)play {
    if (!_isPlaying) AudioOutputUnitStart(_audioUnit);
    _isPlaying = YES;
}

- (void)stop {
    if (_isPlaying) AudioOutputUnitStop(_audioUnit);
    _isPlaying = NO;
}

- (BOOL)isPlaying{
    return _isPlaying;
}

- (void)setFreq:(double)newFreq{
    _generatingFreq = newFreq;
}

- (double)freq {
    return _generatingFreq;
}

- (void)setVolume:(double)newVolume{
    if( newVolume<0.0 ){ newVolume = 0.0; }
    _volume = newVolume;
}

- (void)prepareAudioUnit {
    
    // ------------------------
    // AudioUnit の生成
    
    // AudioComponentDescription から AudioComponent を生成して、AudioUnit に紐づける
    AudioComponentDescription cd;
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_RemoteIO;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = 0;
    cd.componentFlagsMask = 0;
    
    AudioComponent component = AudioComponentFindNext(NULL, &cd);
    AudioComponentInstanceNew(component, &_audioUnit);
    AudioUnitInitialize(_audioUnit);
    
    // ------------------------
    // callback 関数の指定
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
    // AudioUnit の input, output, callback 関数 を紐づける
    AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(AURenderCallbackStruct));
    
    // ------------------------
    // Audioフォーマットの指定
    
    _sampleRate = 44100.0;
    
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = _sampleRate;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
    audioFormat.mChannelsPerFrame = 2;
    audioFormat.mBytesPerPacket = sizeof(SInt32);
    audioFormat.mBytesPerFrame = sizeof(SInt32);
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mBitsPerChannel = 8 * sizeof(SInt32);
    audioFormat.mReserved = 0;
    
    AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &audioFormat, sizeof(audioFormat));
}

static OSStatus renderCallback(void* inRefCon, AudioUnitRenderActionFlags* ioActionFlags, const AudioTimeStamp* inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList* ioData) {
    
    // この callback 関数で audioUnit への input となる音の波形を生成する
    
    SineWaveSound* def = (__bridge SineWaveSound*)inRefCon;
    
    float freq = _generatingFreq * 2.0 * M_PI / def.sampleRate;
    double phase = def.phase;
    
    SInt32 *outL = ioData->mBuffers[0].mData;
    SInt32 *outR = ioData->mBuffers[1].mData;
    
    for (int i = 0; i < inNumberFrames; i++) {
        float wave = sin(phase);
        SInt32 sample = wave * (1 << kAudioUnitSampleFractionBits);
        sample = sample * _volume;
        *outL++ = sample;
        *outR++ = sample;
        phase = phase + freq;
    }
    def.phase = phase;
    
    return noErr;
}


@end
