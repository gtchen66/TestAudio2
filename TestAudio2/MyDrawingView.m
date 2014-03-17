//
//  MyDrawingView.m
//  TestAudio2
//
//  Created by George Chen on 3/5/14.
//  Copyright (c) 2014 George Chen. All rights reserved.
//

#import "MyDrawingView.h"
#import <Accelerate/Accelerate.h>

@interface MyDrawingView ()
@property float myMax;

@property float *minFloatArray;
@property float *maxFloatArray;

@end

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
        self.myMax = 0.0;
        
        self.minFloatArray = nil;
        self.maxFloatArray = nil;
    }
    return self;
}

- (void) setMyData:(NSData *)myData {
    _myData = myData;
//    self.myData = myData;
    
    int num_samples = self.myData.length / 2;

    const short *shortArray = (const short *)[self.myData bytes];
    float *floatArray = (float *)malloc(num_samples * sizeof(float));
    
    vDSP_vflt16(shortArray, 1, floatArray, 1, num_samples);
    
    float maxValue = 0.0;
    vDSP_maxmgv(floatArray, 1, &maxValue, num_samples);
    maxValue = maxValue * 1.1;
    
    NSLog(@">>>> setting mydata in drawing.  length to %d",self.myData.length);
    NSLog(@"maxValue = %f", maxValue);
    self.myMax = maxValue;
    
    float width  = self.frame.size.width;
    float height = self.frame.size.height;

    if (self.minFloatArray == nil) {
        // need to allcoate space
        self.minFloatArray = (float *) malloc(width * sizeof(float));
        self.maxFloatArray = (float *) malloc(width * sizeof(float));
    }
    float *minPtr = self.minFloatArray;
    float *maxPtr = self.maxFloatArray;

    int samp_per_frame = num_samples / width;

    float *tmpArrayPtr;
    int i;
    for (i=0; i<width-2; i++) {
        int samp_start = i*samp_per_frame;
        float localMax = 0.0;
        float localMin = 0.0;
        tmpArrayPtr = &floatArray[samp_start];
        vDSP_maxv(tmpArrayPtr, 1, &localMax, samp_per_frame);
        vDSP_minv(tmpArrayPtr, 1, &localMin, samp_per_frame);
        *minPtr++ = height/2 + (localMin/maxValue * height/2);
        *maxPtr++ = height/2 + (localMax/maxValue * height/2);
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    CGContextRef ct = UIGraphicsGetCurrentContext();
    CGFloat blue[4] = {0.0f, 0.0f, 1.0f, 1.0f};
    CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
    
    SInt16 *sptr = (SInt16 *)[self.myData bytes];
    
    NSLog(@"in drawRect. mydata is %d in length", self.myData.length);
    
    CGContextSetStrokeColor(ct, blue);
    
    CGContextBeginPath(ct);
    CGContextMoveToPoint(ct, 1.0f, height/2);
    int i;
    
    // assume 2-bytes per sample
    int num_samples = self.myData.length / 2;
    int samp_per_frame = num_samples / width;
    NSLog(@"samp_per_frame is %d", samp_per_frame);
    
   
    float ymax = self.myMax;
    
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
        
        float *minPtr = self.minFloatArray;
        float *maxPtr = self.maxFloatArray;
        
        // method 2
        // for every visible pair of pixel, identify min/max
        for (i=0; i<width-2; i++) {
            CGContextAddLineToPoint(ct, i, *minPtr++);
            CGContextAddLineToPoint(ct, i, *maxPtr++);
        }
    }
//    CGContextAddArc(ct, width/2, height/2, width/4, 0, M_PI * 2, 0);
    CGContextStrokePath(ct);
    
    // add a vertical line.
    if (self.percentComplete > 0.0) {
        float xpos = self.percentComplete * width;
        CGContextSetStrokeColor(ct, red);
        CGContextBeginPath(ct);
        CGContextMoveToPoint(ct, xpos, 0);
        CGContextAddLineToPoint(ct, xpos, height);
        CGContextStrokePath(ct);        
    }
    
    NSLog(@"done with drawing");
}

@end
