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
        _lastFreq = _generatingFreq;
        _lastPhase = 0.0;
        _lastWave = 0.0;
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
    if( newFreq < 1.0 ){ newFreq = 1.0; }
    _generatingFreq = newFreq;
}

- (double)freq {
    return _generatingFreq;
}

- (void)setVolume:(double)newVolume{
    if( newVolume<0.0 ){ newVolume = 0.0; }
    _volume = newVolume;
    
    /*
     AudioUnitSetParameter(_audioUnit,
                          kHALOutputParam_Volume,
                          kAudioUnitScope_Global,
                          0,
                          _volume,
                          0);
     */
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
    double wave = def.lastWave;
    
    double s;
    
    SInt32 *outL = ioData->mBuffers[0].mData;
    SInt32 *outR = ioData->mBuffers[1].mData;
    SInt32 sample = 0;
    double vv = def.volume * def.volume * def.volume;
    
    for (int i = 0; i < inNumberFrames; i++) {
        if( def.generatingFreq != def.lastFreq ){
            // 前回とはgeneratingFreqが変わっていた場合でも、なるべく波形を連続的に繋ぐために、
            // 前回のwave値から今回のphaseを逆算する。
            freq = def.generatingFreq * 2.0 * M_PI / def.sampleRate;
            s = wave;
            if(  s > 1.0  ){
                s = 1.0;
            }
            if(  s < -1.0  ){
                s = -1.0;
            }
            s = asin(s) ;
            if( cos(def.lastPhase) < 0.0 ){
                s = M_PI -s;
            }

            phase = s + freq;
            def.lastFreq = def.generatingFreq;
            
            
        }
        
        wave = sin(phase);
        sample = (wave * vv ) * (1 << kAudioUnitSampleFractionBits);
        *outL++ = sample;
        *outR++ = sample;
        
        def.lastPhase = phase;
        
        phase = phase + freq;
        if( phase > 2.0*M_PI ){
            phase = phase - 2.0*M_PI;
        }
    }
    // 次回の準備
    def.lastPhase = phase - freq;
    def.lastWave  = wave;

    return noErr;
    /*
     NSLog(@"lastPhase:%f  s:%f", def.lastPhase , s );
     NSLog(@"sin lastPhase:%f  s:%f", sin(def.lastPhase) , sin(s) );
     NSLog(@"cos lastPhase:%f  s:%f", cos(def.lastPhase) , cos(s) );
     NSLog(@"lastWave:%f  s:%f",def.lastWave , sin(s) );
     if( sin(def.lastPhase)-sin(s)>0.00001 ){
     NSLog(@"!sin :%f  s:%f", sin(def.lastPhase) , sin(s) );
     s=s;
     }
     NSLog(@"sin :%f  s:%f", sin(def.lastPhase) , sin(s) );
     */
}


@end
