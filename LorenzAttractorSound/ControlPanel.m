//
//  ControlPanel.m
//  LorenzAttractorSound
//
//  Created by NSNSN on 2015/04/12.
//  Copyright (c) 2015年 n.seigo. All rights reserved.
//

#import "ControlPanel.h"

@implementation ControlPanel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (IBAction)changeLength:(id)sender {
    [self.graphicsView setLength: [NSNumber numberWithDouble:self.lengthSlider.value].intValue];
}

- (IBAction)changeSpeed:(id)sender {
    [self.graphicsView setSpeed: [NSNumber numberWithDouble:self.speedSlider.value].intValue];
}

- (IBAction)changeVolume:(id)sender {
    [self.graphicsView setVolume:self.volumeSlider.value];
}

- (IBAction)changePitch:(id)sender {
    [self.graphicsView setPitch:self.pitchSlider.value];
}

@end
