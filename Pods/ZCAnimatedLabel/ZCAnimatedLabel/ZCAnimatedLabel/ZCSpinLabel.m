//
//  ZCSpinLabel.m
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 3/17/15.
//  Copyright (c) 2015 overboming. All rights reserved.
//
//  3d transform on image doesn't seem practical in real time on images bigger than a dime
//  use layerBased implementation instead
//
//  duration should be longer to notice full rotation
//

#import "ZCSpinLabel.h"

@implementation ZCSpinLabel

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.onlyDrawDirtyArea = NO;
        self.layerBased = YES;
    }
    return self;
}

- (void) textBlockAttributesInit:(ZCTextBlock *)textBlock
{
    ZCTextBlockLayer *layer = textBlock.textBlockLayer;
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.transform = CATransform3DMakeRotation((M_PI / 2), 0, 1, 0);
    [layer setNeedsDisplay];
    layer.anchorPoint = CGPointMake(0, 0.5);
    layer.position = CGPointMake(textBlock.textBlockLayer.position.x - CGRectGetWidth(textBlock.charRect)/2, textBlock.textBlockLayer.position.y);
    [CATransaction commit];
}


- (void) appearStateLayerChangesForTextBlock: (ZCTextBlock *) textBlock
{
    if (textBlock.progress <= 0) {
        return;
    }
    CGFloat realProgress = M_PI / 2 * ([ZCEasingUtil easeOutBackStartValue:1 endValue:0 time:textBlock.progress]);
    
    //This is to disable implicit animation of CALayer
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    textBlock.textBlockLayer.transform = CATransform3DMakeRotation(realProgress, 0, 1, 1);
    [CATransaction commit];
}



@end
