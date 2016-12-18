//
//  UIViewController+Chameleon.h
//  Chameleon
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChameleonEnums.h"

@interface UIViewController (Chameleon)

/**
 *  Sets the color theme for the specified view controller using a primary color and the specified content style.
 *
 *  @param primaryColor   The primary color.
 *  @param contentStyle   The contentStyle.
 *
 *  @since 2.0
 */
- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
                 withContentStyle:(UIContentStyle)contentStyle;

/**
 *  Sets the color theme for the specified view controller using a primary color, secondary color, and the specified content style.
 *
 *  @param primaryColor   The primary color.
 *  @param secondaryColor The secondary color.
 *  @param contentStyle   The contentStyle.
 *
 *  @since 2.0
 */
- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
               withSecondaryColor:(UIColor *)secondaryColor
                  andContentStyle:(UIContentStyle)contentStyle;

/**
 *  Sets the color theme for the specified view controller using a primary color, secondary color, font name, and the specified content style.
 *
 *  @param primaryColor   The primary color.
 *  @param secondaryColor The secondary color.
 *  @param fontName       The main font to use for all text-based elements.
 *  @param contentStyle   The contentStyle.
 *
 *  @since 2.0
 */
- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
               withSecondaryColor:(UIColor *)secondaryColor
                    usingFontName:(NSString *)fontName
                  andContentStyle:(UIContentStyle)contentStyle;

/**
 *  Sets the status bar style for the specified @c UIViewController and all its child controllers.
 *
 *  @param statusBarStyle The style of the device's status bar.
 *
 *  @note Chameleon introduces a new @c statusBarStyle called @c UIStatusBarStyleContrast.
 *
 *  @since 2.0
 */
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle;

@end
