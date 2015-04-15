//
//  ViewController.m
//  LorenzAttractorSound
//
//  Created by NSNSN on 2015/04/12.
//  Copyright (c) 2015年 n.seigo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)stopOrStart:(id)sender {
    if( self.lorenzGraphicsView.isRunning ){
        [self.lorenzGraphicsView stop];
    }else{
        [self.lorenzGraphicsView start];
    }
}

- (IBAction)changeLength:(id)sender {
    [self.lorenzGraphicsView setLength:[NSNumber numberWithDouble:((UISlider*)sender).value].intValue];
}

- (IBAction)changeSpeed:(id)sender {
    [self.lorenzGraphicsView setSpeed:[NSNumber numberWithDouble:((UISlider*)sender).value].intValue];
}

- (IBAction)changeVolume:(id)sender {
    [self.lorenzGraphicsView setVolume:((UISlider*)sender).value];
}

- (IBAction)changePitch:(id)sender {
    [self.lorenzGraphicsView setPitch:((UISlider*)sender).value];
}

@end
