//
//  MyDrawingView.m
//  TestAudio2
//
//  Created by George Chen on 3/5/14.
//  Copyright (c) 2014 George Chen. All rights reserved.
//

#import "MyDrawingView.h"

@implementation MyDrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setBackgroundColor:[UIColor greenColor]];
        self.myData = [[NSData alloc] init];
        
    }
    return self;
}

- (void) setMyData:(NSData *)myData {
    _myData = myData;
//    self.myData = myData;
    NSLog(@"setting mydata in drawing.  length to %d",self.myData.length);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    CGContextRef ct = UIGraphicsGetCurrentContext();
    CGFloat blue[4] = {0.0f, 0.0f, 1.0f, 1.0f};
    
    SInt16 *sptr = (SInt16 *)[self.myData bytes];
    
    NSLog(@"in drawRect. mydata is %d in length", self.myData.length);
    
    CGContextSetStrokeColor(ct, blue);
    
    CGContextBeginPath(ct);
    CGContextMoveToPoint(ct, 1.0f, height/2);
    int i;
    // find abs of min/max
    // first 100 values:
//    for (i=0; i<num_samples; i++) {
//        int yval = 0;
//        if (i < self.myData.length) {
//            yval = *sptr++;
//            NSLog(@"initial (%d) = %d",i,yval);
//        }
//    }
    // assume 2-bytes per sample
    int num_samples = self.myData.length / 2;
    int samp_per_frame = num_samples / width;
    NSLog(@"samp_per_frame is %d", samp_per_frame);
    
    float ymax = 0;
    for (i=0; i<num_samples; i++) {
        int yval = *sptr++;
        ymax = MAX(ymax, ABS(yval));
    }
    ymax = ymax*1.1f;
    
    sptr = (SInt16 *) [self.myData bytes];
    
    // method 1
    if (self.method == 1) {
        // plot every point, let pixel resolution determine where to draw
        NSLog(@"running with method 1.  %d samples",num_samples);
        for (i=0; i<num_samples; i=i+20) {
            
            float xpos = i*(width - 5)/num_samples;
            float yval = *sptr;
            sptr = sptr + 20;
            
            float ypos = height/2 + (yval/ymax * height/2);
            CGContextAddLineToPoint(ct, xpos, ypos);
        }
        NSLog(@"done with method 1");
        
    } else if (self.method == 2) {
        
        // method 2
        // for every visible pair of pixel, identify min/max
        for (i=0; i<width-5; i++) {
            int samp_start = i*samp_per_frame;
            int samp_end   = samp_start + (2*samp_per_frame);
            float yval_min = 0;
            float yval_max = 0;
            int yval = 0;
            int j;
            for (j=samp_start; j<samp_end; j++) {
                if (j < self.myData.length) {
                    yval = *sptr++;
                    yval_min = MIN(yval_min, yval);
                    yval_max = MAX(yval_max, yval);
                    }
            }
            int ypos1 = height/2 + (yval_min/ymax * height/2);
            CGContextAddLineToPoint(ct, i, ypos1);
            i++;
            int ypos2 = height/2 + (yval_max/ymax * height/2);
            CGContextAddLineToPoint(ct, i, ypos2);
            // NSLog(@"(%d, %f -> %d, %f -> %d", i, yval_min, ypos1, yval_max, ypos2);
        }
    }
//    CGContextAddArc(ct, width/2, height/2, width/4, 0, M_PI * 2, 0);
    CGContextStrokePath(ct);
    NSLog(@"done with drawing");
}

@end
