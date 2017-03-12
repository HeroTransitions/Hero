//
//  UIView+ChameleonPrivate.h
//  Chameleon
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ChameleonPrivate)

- (BOOL)isTopViewInWindow;
- (UIView *)findTopMostViewForPoint:(CGPoint)point;

@end
