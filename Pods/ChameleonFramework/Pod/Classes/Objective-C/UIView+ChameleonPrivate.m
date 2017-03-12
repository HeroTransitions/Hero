//
//  UIView+ChameleonPrivate.m
//  Chameleon
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import "UIView+ChameleonPrivate.h"

@implementation UIView (ChameleonPrivate)

- (BOOL)isTopViewInWindow {
    
    if (!self.window) {
        return NO;
    }
    
    CGPoint centerPointInSelf = CGPointMake(CGRectGetMidX(self.bounds),
                                            CGRectGetMidY(self.bounds));
    
    CGPoint centerPointOfSelfInWindow = [self convertPoint:centerPointInSelf
                                                    toView:self.window];
    
    UIView *view = [self.window findTopMostViewForPoint:centerPointOfSelfInWindow];
    BOOL isTopMost = view == self || [view isDescendantOfView:self];
    
    return isTopMost;
}

- (UIView *)findTopMostViewForPoint:(CGPoint)point {
    
    for (int i = (int)self.subviews.count - 1; i >= 0; i--) {
        
        UIView *subview = self.subviews[i];
        
        if (!subview.hidden && CGRectContainsPoint(subview.frame, point) && subview.alpha > 0.01) {
            CGPoint pointConverted = [self convertPoint:point toView:subview];
            return [subview findTopMostViewForPoint:pointConverted];
        }
    }
    
    return self;
}

@end
