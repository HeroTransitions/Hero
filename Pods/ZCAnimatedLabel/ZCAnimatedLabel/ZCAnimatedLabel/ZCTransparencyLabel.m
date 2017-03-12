//
//  ZCTransparencyLabel.m
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 2/28/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import "ZCTransparencyLabel.h"

@implementation ZCTransparencyLabel

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.onlyDrawDirtyArea = YES;
    }
    return self;
}

- (void) textBlockAttributesInit:(ZCTextBlock *)textBlock
{
    //customValue used as delay time
    textBlock.startDelay = drand48();
    textBlock.duration = drand48() * 2 + 1;
}

- (void) appearStateDrawingForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock
{
    CGFloat alpha = [ZCEasingUtil easeOutWithStartValue:0 endValue:1 time:textBlock.progress];
    //skip very low alpha
    if (alpha < 0.01) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIColor *color = [textBlock.derivedTextColor colorWithAlphaComponent:alpha];
    textBlock.textColor = color;
    [textBlock.derivedAttributedString drawInRect:textBlock.charRect];
    CGContextRestoreGState(context);
}

- (void) disappearStateDrawingForRect:(CGRect)rect textBlock:(ZCTextBlock *) textBlock
{
    CGFloat alpha = [ZCEasingUtil easeOutWithStartValue:1 endValue:0 time:textBlock.progress];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIColor *color = [textBlock.derivedTextColor colorWithAlphaComponent:alpha];
    textBlock.textColor = color;
    [textBlock.derivedAttributedString drawInRect:textBlock.charRect];
    CGContextRestoreGState(context);
}

@end