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

- (id)init {
    self = [super init];
    if (self != nil){
        _generatingFreq = 440.0;
        self.lastPhase = 0.0;
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
    
    
    _lastWave = 0.0;
}

static OSStatus renderCallback(void* inRefCon, AudioUnitRenderActionFlags* ioActionFlags, const AudioTimeStamp* inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList* ioData) {
    
    // この callback 関数で audioUnit への input となる音の波形を生成する
    
    SineWaveSound* def = (__bridge SineWaveSound*)inRefCon;
    
    float freq = def.generatingFreq * 2.0 * M_PI / def.sampleRate;
    double phase = def.lastPhase;
    
    // 前回とはgeneratingFreqが変わっていた場合でも、なるべく波形を連続的に繋ぐために、
    // 前回のwave値から始まりのphaseを逆算する。
    double s = def.lastWave / def.volume;
    if(  s > 1.0  ){ s = 1.0; }
    if(  s < -1.0  ){ s = -1.0; }
    s = asin(s) * ( def.sampleRate/(def.generatingFreq* 2.0 * M_PI) );
    s = s * freq;
    if( cos(def.lastPhase) < 0.0 ){
        s = M_PI -s;
    }
    phase = s + freq;
    
    //
    SInt32 *outL = ioData->mBuffers[0].mData;
    SInt32 *outR = ioData->mBuffers[1].mData;
    SInt32 sample = 0;
    float wave = 0.0;
    
    for (int i = 0; i < inNumberFrames; i++) {
        wave = sin(phase) * def.volume;
        sample = wave * (1 << kAudioUnitSampleFractionBits);
        *outL++ = sample;
        *outR++ = sample;
        
        phase = phase + freq;
    }
    // 次回の準備
    def.lastPhase = phase - freq;
    def.lastWave  = sin(def.lastPhase) * def.volume;
    
    return noErr;
    /*
     NSLog(@"lastPhase:%f  s:%f", def.lastPhase , s );
     NSLog(@"sin lastPhase:%f  s:%f", sin(def.lastPhase) , sin(s) );
     NSLog(@"cos lastPhase:%f  s:%f", cos(def.lastPhase) , cos(s) );
     NSLog(@"lastWave:%f  s:%f",def.lastWave , sin(s) * volume  );
     */
}


@end
