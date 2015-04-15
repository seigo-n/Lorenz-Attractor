//
//  SineWaveSound.h
//  LorenzAttractorSound
//
//  Created by NSNSN on 2015/04/12.
//  Copyright (c) 2015年 n.seigo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

@interface SineWaveSound : NSObject

@property(nonatomic) double lastPhase;
@property(nonatomic) float lastWave;
@property(nonatomic) Float64 sampleRate;
@property(nonatomic) double generatingFreq;
@property(nonatomic) double volume;

- (void)play;
- (void)stop;
- (BOOL)isPlaying;
- (void)setFreq:(double)newFreq;
- (double)freq;
- (void)setVolume:(double)newVolume;

@end
