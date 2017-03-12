//
//  ZCFallLabel.m
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 2/28/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import "ZCFallLabel.h"

#import "ZCDuangLabel.h"

@implementation ZCFallLabel

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.onlyDrawDirtyArea = YES;
    }
    return self;
}

- (void) textBlockAttributesInit: (ZCTextBlock *) textBlock
{
    textBlock.customValue = @((int)(arc4random() % 7) - 3);
    
}

- (CGRect) redrawAreaForRect:(CGRect)rect textBlock:(ZCTextBlock *) textBlock
{
    CGRect charRect = textBlock.charRect;
    return CGRectMake(charRect.origin.x - textBlock.derivedFont.pointSize / 2, charRect.origin.y - textBlock.derivedFont.pointSize * 5, charRect.size.width + textBlock.derivedFont.pointSize, charRect.size.height + textBlock.derivedFont.pointSize * 5);
}

- (void) appearStateDrawingForRect: (CGRect) rect textBlock:(ZCTextBlock *) textBlock
{
    CGFloat height = [ZCEasingUtil bounceWithStiffness:0.01 numberOfBounces:1 time:textBlock.progress shake:NO shouldOvershoot:NO startValue:CGRectGetMaxY(textBlock.charRect) - textBlock.derivedFont.pointSize * 5  endValue:CGRectGetMaxY(textBlock.charRect)];
    
    CGFloat alpha = textBlock.progress < 0.2 ? [ZCEasingUtil easeInWithStartValue:0 endValue:1 time:textBlock.progress * 5] : 1;
    //skip very low alpha
    if (alpha < 0.01 || textBlock.progress <= 0) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMidX(textBlock.charRect), height);
    CGFloat rotateValue = 0;
    CGFloat segment = 0.2;
    CGFloat maxRotate = [textBlock.customValue integerValue] * M_PI / 32;
    if (textBlock.progress <= segment) {
        rotateValue = maxRotate;
    }
    else {
        CGFloat newTime = (textBlock.progress - segment)/(1 - segment);
        rotateValue = [ZCEasingUtil bounceWithStiffness:0.01 numberOfBounces:2 time:newTime shake:NO shouldOvershoot:YES startValue:maxRotate endValue:0];
    }
    CGContextRotateCTM(context, rotateValue);

    UIColor *color = [textBlock.derivedTextColor colorWithAlphaComponent:alpha];
    CGRect newRect = CGRectMake(-textBlock.charRect.size.width / 2, -textBlock.charRect.size.height, textBlock.charRect.size.width, textBlock.charRect.size.height);
    textBlock.textColor = color; //override color
    [textBlock.derivedAttributedString drawInRect:newRect];
    CGContextRestoreGState(context);
}



@end
