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
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    CGContextRef ct = UIGraphicsGetCurrentContext();
    CGFloat blue[4] = {0.0f, 0.0f, 1.0f, 1.0f};
    
    CGContextSetStrokeColor(ct, blue);
    
    CGContextBeginPath(ct);
    CGContextMoveToPoint(ct, 1.0f, height/2);
    CGContextAddArc(ct, width/2, height/2, width/4, 0, M_PI * 2, 0);
    CGContextStrokePath(ct);
}

@end
