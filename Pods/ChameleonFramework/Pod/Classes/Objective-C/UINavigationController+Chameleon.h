//
//  UINavigationController+Chameleon.h
//  ChameleonDemo
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChameleonEnums.h"

@interface UINavigationController (Chameleon)

/**
 *  Sets the status bar style for the specified @c UINavigationController and all its child controllers.
 *
 *  @param statusBarStyle The style of the device's status bar.
 *
 *  @note Chameleon introduces a new @c statusBarStyle called @c UIStatusBarStyleContrast.
 *
 *  @since 2.0
 */
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle;

/**
 *  Hides the hairline view at the bottom of a navigation bar. The default value is @c NO.
 *
 *  @since 2.0.3
 */
@property (nonatomic, assign) BOOL hidesNavigationBarHairline;

@end
