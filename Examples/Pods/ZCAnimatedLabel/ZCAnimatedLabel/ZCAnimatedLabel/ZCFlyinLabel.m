//
//  ZCFlyinLabel.m
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 2/28/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import "ZCFlyinLabel.h"


@implementation ZCFlyinLabel

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.onlyDrawDirtyArea = YES;
    }
    return self;
}

- (void) textBlockAttributesInit:(ZCTextBlock *)textBlock
{
}

- (CGRect) redrawAreaForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock
{
    CGRect charRect = textBlock.charRect;
    return CGRectMake(0, charRect.origin.y, rect.size.width, rect.size.height - charRect.origin.y);
}

- (void) appearStateDrawingForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock
{
    CGFloat scale = [ZCEasingUtil easeOutWithStartValue:5 endValue:1 time:textBlock.progress];
    CGFloat alpha = [ZCEasingUtil easeOutWithStartValue:0 endValue:1 time:textBlock.progress];
    //skip very low alpha
    if (alpha < 0.01) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGFloat flyDirectionOffset = (1-textBlock.progress) * textBlock.derivedFont.pointSize * 2;
    CGContextTranslateCTM(context, CGRectGetMidX(textBlock.charRect), CGRectGetMidY(textBlock.charRect));
    CGContextScaleCTM(context, scale, scale);
    UIColor *color = [textBlock.derivedTextColor colorWithAlphaComponent:alpha];
    CGRect rotatedRect = CGRectMake(-textBlock.charRect.size.width / 2 + flyDirectionOffset, - textBlock.charRect.size.height / 2 + flyDirectionOffset, textBlock.charRect.size.width, textBlock.charRect.size.height);
    textBlock.textColor = color;
    [textBlock.derivedAttributedString drawInRect:rotatedRect];
    CGContextRestoreGState(context);
}


@end