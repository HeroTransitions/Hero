//
//  ZCRevealLabel.m
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 3/2/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import "ZCRevealLabel.h"

@implementation ZCRevealLabel

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.onlyDrawDirtyArea = NO;
    }
    return self;
}

- (void) textBlockAttributesInit:(ZCTextBlock *)textBlock
{
}

- (void) appearStateDrawingForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock
{
    if (textBlock.progress <= 0.0f) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect boundingBox = textBlock.charRect;
    
    CGFloat maxRadius = boundingBox.size.width > boundingBox.size.height ? boundingBox.size.width : boundingBox.size.height;
    CGFloat radius = [ZCEasingUtil easeOutWithStartValue:0 endValue:maxRadius time:textBlock.progress];

    CGFloat centerX = CGRectGetMidX(boundingBox);
    CGFloat centerY = CGRectGetMidY(boundingBox);
    CGContextAddEllipseInRect(context, CGRectMake(centerX - radius, centerY - radius, 2 * radius, 2 * radius));
    CGContextEOClip(context);
    
    [textBlock.derivedAttributedString drawInRect:textBlock.charRect];
    CGContextRestoreGState(context);
}
@end
