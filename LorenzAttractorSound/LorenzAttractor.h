//
//  LorenzAttractor.h
//  LorenzAttractorSound
//
//  Created by NSNSN on 2015/04/12.
//  Copyright (c) 2015年 n.seigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"AudioToolbox/AudioToolbox.h"
#import "SineWaveSound.h"

@interface LorenzAttractor : UIView{
    NSTimer* _timer;
    NSMutableArray* _linePoints;
    SineWaveSound*  _sineWaveSound;
}

- (void)setSpeed:(int)newSpeed;
- (void)setLength:(int)newLength;
- (void)setVolume:(double)newVolume;
- (void)setPitch:(double)newPitch;
- (void)start;
- (void)stop;
- (BOOL)isRunning;



@end
