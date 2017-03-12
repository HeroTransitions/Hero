//
//  ZCDuangLabel.m
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 2/28/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import "ZCDuangLabel.h"

@implementation ZCDuangLabel

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.onlyDrawDirtyArea = YES;
    }
    return self;
}

- (void) appearStateDrawingForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock
{
    if (textBlock.progress <= 0) {
        return;
    }
    CGFloat realProgress = [ZCEasingUtil bounceWithStiffness:kZCAnimatedLabelStiffnessMedium numberOfBounces:3 time:textBlock.progress shake:YES shouldOvershoot:YES];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMidX(textBlock.charRect), CGRectGetMaxY(textBlock.charRect));
    CGContextScaleCTM(context, 1, realProgress);
    CGRect newRect = CGRectMake(-textBlock.charRect.size.width / 2, -textBlock.charRect.size.height, textBlock.charRect.size.width, textBlock.charRect.size.height);
    [textBlock.derivedAttributedString drawInRect:newRect];
    CGContextRestoreGState(context);
}




@end
