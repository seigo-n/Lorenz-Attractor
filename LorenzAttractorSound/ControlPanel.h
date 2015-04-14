//
//  ControlPanel.h
//  LorenzAttractorSound
//
//  Created by NSNSN on 2015/04/12.
//  Copyright (c) 2015年 n.seigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LorenzAttractor.h"

@interface ControlPanel : UIView

@property (weak, nonatomic) IBOutlet UISlider *lengthSlider;
- (IBAction)changeLength:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
- (IBAction)changeSpeed:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
- (IBAction)changeVolume:(id)sender;

@property (weak, nonatomic) IBOutlet LorenzAttractor *graphicsView;

@property (weak, nonatomic) IBOutlet UILabel *freqLabel;

@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
- (IBAction)changePitch:(id)sender;

- (void) setFreqCounterLabel:(double)freq;

@end
