//
//  ZCShapeshiftLabel.m
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 2/26/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import "ZCShapeshiftLabel.h"

@implementation ZCShapeshiftLabel

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.onlyDrawDirtyArea = NO;
    }
    return self;
}

- (void) appearStateDrawingForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock
{
    CGFloat alpha = [ZCEasingUtil easeInWithStartValue:0 endValue:1 time:textBlock.progress];
    if (alpha < 0.01) {
        return;
    }
    CGFloat realProgress = [ZCEasingUtil bounceWithStiffness:kZCAnimatedLabelStiffnessMedium numberOfBounces:1 time:textBlock.progress shake:YES shouldOvershoot:NO];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMidX(textBlock.charRect), CGRectGetMidY(textBlock.charRect));
    CGContextRotateCTM(context, M_PI / 2 * (1 - realProgress));
    
    CGFloat scaleY = textBlock.progress < 0.5 ? 0.3 : [ZCEasingUtil bounceWithStartValue:0.3 endValue:1 time:(textBlock.progress-0.5)/0.7];
    CGContextScaleCTM(context, 1, scaleY);
    UIColor *color = [textBlock.derivedTextColor colorWithAlphaComponent:alpha];
    CGRect rotatedRect = CGRectMake(-textBlock.charRect.size.width / 2, - textBlock.charRect.size.height / 2, textBlock.charRect.size.width, textBlock.charRect.size.height);
    textBlock.textColor = color;
    [textBlock.derivedAttributedString drawInRect:rotatedRect];
    CGContextRestoreGState(context);
}



@end
