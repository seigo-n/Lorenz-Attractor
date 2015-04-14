//
//  LorenzAttractor.m
//  MovingLorenzAttractor
//
//  Created by NSNSN on 2015/04/11.
//  Copyright (c) 2015年 n.seigo. All rights reserved.
//

#import "LorenzAttractor.h"
#import "ControlPanel.h"

@implementation LorenzAttractor

double A,B,C,D;
double x,y,z;
double xRatio=6.0;
double zRatio=-6.0;
int speed =5;
int lineLength=200;
double _pitch = 2000.0;

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        
        A=10.0;
        B=28.0;
        C=8.0/3.0;
        D=0.005;
        
        x=1.0;
        y=1.0;
        z=1.0;
        
        _linePoints = [NSMutableArray array];
        
        _timer=[NSTimer scheduledTimerWithTimeInterval:1.0f/30.0f
                                                target:self
                                              selector:@selector(onTick:)
                                              userInfo:nil
                                               repeats:YES];
        _sineWaveSound = [SineWaveSound new];
        [_sineWaveSound setVolume:0.3];

    }
    return self;
}


-(void)drawRect:(CGRect)rect{
    
    if (_linePoints.count>1 ) {
        double ow,oh;
        
        ow = self.frame.size.width/2.0;
        oh = self.frame.size.height/2.0;
        
        CGPoint p;
        UIBezierPath *lines = [UIBezierPath bezierPath];
        
        p = [_linePoints[0] CGPointValue];
        p = CGPointMake( p.x*xRatio+ow , p.y*zRatio+oh);
        [lines moveToPoint:p ];
        
        for (int i=1; i<_linePoints.count; ++i){
            p = [_linePoints[i] CGPointValue];
            p = CGPointMake( p.x*xRatio+ow , p.y*zRatio+oh);
            [lines addLineToPoint:p ];
        }
        
        // 色
        [[UIColor greenColor] setStroke];
        // 幅
        lines.lineWidth = 1;
        // 描画
        [lines stroke];
        
        

    }
}

- (void)onTick:(NSTimer*)timer {
    double dx,dy,dz;
    
    if ( _linePoints.count<lineLength ) {
        //起動初回、または、lengthが長いほうへ変更された場合。_linePoints.count=lineLengthになるまで点を追加。
        
        int addCount = lineLength - (int)_linePoints.count;
        for(int i=0; i<addCount; ++i){
            dx=A*(y-x);
            dy=x*(B-z)-y;
            dz=x*y-C*z;
            x=x+D*dx;
            y=y+D*dy;
            z=z+D*dz;
            
            [_linePoints addObject:[NSValue valueWithCGPoint:CGPointMake( x , z-(50.0+2.0)/2.0 )] ];
        }
    } else {
        //lengthが短いほうへ変更された場合、余分になった数だけ古いほうから点を削除
        
        int removeCount = (int)_linePoints.count - lineLength;
        for(int i=0; i<removeCount; ++i){
            [_linePoints removeObjectAtIndex:0];
        }
        
        //通常の更新（_linePoints.count=lineLengthの状態）。speed個だけ、古い点を消して、新しい点を追加。
        for(int i=0; i<speed; ++i){
            dx=A*(y-x);
            dy=x*(B-z)-y;
            dz=x*y-C*z;
            x=x+D*dx;
            y=y+D*dy;
            z=z+D*dz;
            
            [_linePoints removeObjectAtIndex:0];
            [_linePoints addObject:[NSValue valueWithCGPoint:CGPointMake( x , z-(50.0+2.0)/2.0 )] ];
        }
        
        // 音出し
        double sz = z-(50.0+2.0)/2.0;
        double frq = _pitch + (sqrt( x*x + y*y + sz*sz)-10.0) * ([NSNumber numberWithInt:lineLength].doubleValue*0.3+5.0);
        [_sineWaveSound setFreq:frq];
        if( !_sineWaveSound.isPlaying ){ [_sineWaveSound play]; }

        //周波数表示
        [(ControlPanel*)self.superview setFreqCounterLabel:frq];
        
    }
    
    [self setNeedsDisplay];    //再描画
    
}

- (void)setSpeed:(int)newSpeed {
    if( newSpeed<1 ){ newSpeed=1; }
    if( newSpeed>=lineLength ){ newSpeed=lineLength-1; }
    speed = newSpeed;
}

- (void)setLength:(int)newLength {
    if( newLength<2 ){ newLength=2; }
    lineLength = newLength;
}

- (void)setVolume:(double)newVolume {
    [_sineWaveSound setVolume:newVolume];
}

- (void)setPitch:(double)newPitch {
    if( newPitch<0.0 ){ newPitch = 0.0; }
    _pitch = newPitch;
}
/*
 NSLog(@"slider value %f",self.lineLength.value);
 
 NSLog(@"(%ld,%ld)",(long)ow,(long)oh);
 NSLog(@"  A:%f,B:%f,C:%f,D:%f",A,B,C,D);
 NSLog(@"count %ld",_linePoints.count);
 self.paramA.text = [NSString stringWithFormat:@"%4f",A];
 NSLog(@"%@",self.paramA.text);
 */

@end
