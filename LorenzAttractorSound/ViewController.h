//
//  ViewController.h
//  LorenzAttractorSound
//
//  Created by NSNSN on 2015/04/12.
//  Copyright (c) 2015年 n.seigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LorenzAttractor.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet LorenzAttractor *lorenzGraphicsView;
- (IBAction)stopOrStart:(id)sender;

@end

