//
//  ChameleonInternal.h
//  Chameleon
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ChameleonConstants.h"
#import "ChameleonEnums.h"
#import "ChameleonMacros.h"

#import "NSArray+Chameleon.h"
#import "UIColor+Chameleon.h"
#import "UINavigationController+Chameleon.h"
#import "UIViewController+Chameleon.h"

@interface Chameleon : NSObject

#pragma mark - Global Theming

/**
 *  Set a global theme using a primary color and the specified content style.
 *
 *  @param primaryColor The primary color to theme all controllers with.
 *  @param contentStyle The contentStyle.
 *
 *  @note By default the secondary color will be a darker shade of the specified primary color.
 *
 *  @since 2.0
 */
+ (void)setGlobalThemeUsingPrimaryColor:(UIColor *)primaryColor
                 withContentStyle:(UIContentStyle)contentStyle;

/**
 *  Set a global theme using a primary color, secondary color, and the specified content style.
 *
 *  @param primaryColor   The primary color to theme all controllers with.
 *  @param secondaryColor The secondary color to theme all controllers with.
 *  @param contentStyle   The contentStyle.
 *
 *  @since 2.0
 */
+ (void)setGlobalThemeUsingPrimaryColor:(UIColor *)primaryColor
               withSecondaryColor:(UIColor *)secondaryColor
                  andContentStyle:(UIContentStyle)contentStyle;

/**
 *  Set a global theme using a primary color, secondary color, font name, and the specified content style.
 *
 *  @param primaryColor   The primary color to theme all controllers with.
 *  @param secondaryColor The secondary color to theme all controllers with.
 *  @param fontName       The default font for all text-based UI elements.
 *  @param contentStyle   The contentStyle.
 *
 *  @since 2.0
 */
+ (void)setGlobalThemeUsingPrimaryColor:(UIColor *)primaryColor
               withSecondaryColor:(UIColor *)secondaryColor
                    usingFontName:(NSString *)fontName
                  andContentStyle:(UIContentStyle)contentStyle;

@end
