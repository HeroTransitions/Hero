
//  UIColor+Chameleon.h

/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014-2015 Vicc Alexander.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enums

/**
 *  Defines the gradient style and direction of the gradient color.
 *
 *  @since 1.0
 */
typedef NS_ENUM (NSUInteger, UIGradientStyle) {
    /**
     *  Returns a gradual blend between colors originating at the leftmost point of an object's frame, and ending at the rightmost point of the object's frame.
     *
     *  @since 1.0
     */
    UIGradientStyleLeftToRight,
    /**
     *  Returns a gradual blend between colors originating at the center of an object's frame, and ending at all edges of the object's frame. NOTE: Supports a Maximum of 2 Colors.
     *
     *  @since 1.0
     */
    UIGradientStyleRadial,
    /**
     *  Returns a gradual blend between colors originating at the topmost point of an object's frame, and ending at the bottommost point of the object's frame.
     *
     *  @since 1.0
     */
    UIGradientStyleTopToBottom
};

/**
 *  Defines the shade of a any flat color.
 *
 *  @since 1.0
 */
typedef NS_ENUM (NSInteger, UIShadeStyle) {
    /**
     *  Returns the light shade version of a flat color.
     *
     *  @since 1.0
     */
    UIShadeStyleLight,
    /**
     *  Returns the dark shade version of a flat color.
     *
     *  @since 1.0
     */
    UIShadeStyleDark
};


@interface UIColor (Chameleon)

#pragma mark - Instance Variables

/**
 *  Stores an object's UIColor image if the UIColor was created using colorWithPatternImage.
 *
 *  @since 1.0
 */

@property (nonatomic, strong) UIImage *gradientImage;

#pragma mark - Quick Shorthand Macros

// Quick & Easy Shorthand for RGB x HSB Colors
// The reason we don't import our Macro file is to prevent naming conflicts.
#define rgba(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define rgb(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]
#define hsba(h,s,b,a) [UIColor colorWithHue:h/360.0f saturation:s/100.0f brightness:b/100.0f alpha:a]
#define hsb(h,s,b) [UIColor colorWithHue:h/360.0f saturation:s/100.0f brightness:b/100.0f alpha:1.0]

#pragma mark - Light Shades

#if UIKIT_DEFINE_AS_PROPERTIES
/**
 *  Returns a flat color object whose HSB values are 0.0, 0.0, 0.17 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatBlackColor;

/**
 *  Returns a flat color object whose HSB values are 0.62, 0.50, 0.63 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatBlueColor;

/**
 *  Returns a flat color object whose HSB values are 0.07, 0.45, 0.37 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatBrownColor;

/**
 *  Returns a flat color object whose HSB values are 0.07, 0.31, 0.64 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatCoffeeColor;

/**
 *  Returns a flat color object whose HSB values are 0.38, 0.45, 0.37 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatForestGreenColor;

/**
 *  Returns a flat color object whose HSB values are 0.51, 0.10, 0.65 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatGrayColor;

/**
 *  Returns a flat color object whose HSB values are 0.40, 0.77, 0.80 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatGreenColor;

/**
 *  Returns a flat color object whose HSB values are 0.21, 0.70, 0.78 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatLimeColor;

/**
 *  Returns a flat color object whose HSB values are 0.79, 0.51, 0.71 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatMagentaColor;

/**
 *  Returns a flat color object whose HSB values are 0.01, 0.65, 0.47 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatMaroonColor;

/**
 *  Returns a flat color object whose HSB values are 0.47, 0.86, 0.74 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatMintColor;

/**
 *  Returns a flat color object whose HSB values are 0.58, 0.45, 0.37 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatNavyBlueColor;

/**
 *  Returns a flat color object whose HSB values are 0.08, 0.85, 0.90 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatOrangeColor;

/**
 *  Returns a flat color object whose HSB values are 0.90, 0.49, 0.96 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatPinkColor;

/**
 *  Returns a flat color object whose HSB values are 0.83, 0.45, 0.37 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatPlumColor;

/**
 *  Returns a flat color object whose HSB values are 0.62, 0.24, 0.95 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatPowderBlueColor;

/**
 *  Returns a flat color object whose HSB values are 0.70, 0.52, 0.77 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatPurpleColor;

/**
 *  Returns a flat color object whose HSB values are 0.02, 0.74, 0.91 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatRedColor;

/**
 *  Returns a flat color object whose HSB values are 0.12, 0.25, 0.94 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatSandColor;

/**
 *  Returns a flat color object whose HSB values are 0.57, 0.76, 0.86 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatSkyBlueColor;

/**
 *  Returns a flat color object whose HSB values are 0.54, 0.55, 0.51 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatTealColor;

/**
 *  Returns a flat color object whose HSB values are 0.99, 0.53, 0.94 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatWatermelonColor;

/**
 *  Returns a flat color object whose HSB values are 0.53, 0.02, 0.95 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatWhiteColor;

/**
 *  Returns a flat color object whose HSB values are 0.13, 0.99, 1.00 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatYellowColor;
#else

/**
 *  Returns a flat color object whose HSB values are 0.0, 0.0, 0.17 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatBlackColor;

/**
 *  Returns a flat color object whose HSB values are 0.62, 0.50, 0.63 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatBlueColor;

/**
 *  Returns a flat color object whose HSB values are 0.07, 0.45, 0.37 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatBrownColor;

/**
 *  Returns a flat color object whose HSB values are 0.07, 0.31, 0.64 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatCoffeeColor;

/**
 *  Returns a flat color object whose HSB values are 0.38, 0.45, 0.37 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatForestGreenColor;

/**
 *  Returns a flat color object whose HSB values are 0.51, 0.10, 0.65 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatGrayColor;

/**
 *  Returns a flat color object whose HSB values are 0.40, 0.77, 0.80 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatGreenColor;

/**
 *  Returns a flat color object whose HSB values are 0.21, 0.70, 0.78 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatLimeColor;

/**
 *  Returns a flat color object whose HSB values are 0.79, 0.51, 0.71 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatMagentaColor;

/**
 *  Returns a flat color object whose HSB values are 0.01, 0.65, 0.47 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatMaroonColor;

/**
 *  Returns a flat color object whose HSB values are 0.47, 0.86, 0.74 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatMintColor;

/**
 *  Returns a flat color object whose HSB values are 0.58, 0.45, 0.37 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatNavyBlueColor;

/**
 *  Returns a flat color object whose HSB values are 0.08, 0.85, 0.90 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatOrangeColor;

/**
 *  Returns a flat color object whose HSB values are 0.90, 0.49, 0.96 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatPinkColor;

/**
 *  Returns a flat color object whose HSB values are 0.83, 0.45, 0.37 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatPlumColor;

/**
 *  Returns a flat color object whose HSB values are 0.62, 0.24, 0.95 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatPowderBlueColor;

/**
 *  Returns a flat color object whose HSB values are 0.70, 0.52, 0.77 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatPurpleColor;

/**
 *  Returns a flat color object whose HSB values are 0.02, 0.74, 0.91 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatRedColor;

/**
 *  Returns a flat color object whose HSB values are 0.12, 0.25, 0.94 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatSandColor;

/**
 *  Returns a flat color object whose HSB values are 0.57, 0.76, 0.86 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatSkyBlueColor;

/**
 *  Returns a flat color object whose HSB values are 0.54, 0.55, 0.51 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatTealColor;

/**
 *  Returns a flat color object whose HSB values are 0.99, 0.53, 0.94 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatWatermelonColor;

/**
 *  Returns a flat color object whose HSB values are 0.53, 0.02, 0.95 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatWhiteColor;

/**
 *  Returns a flat color object whose HSB values are 0.13, 0.99, 1.00 and whose alpha value is 1.0.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatYellowColor;

#endif

#pragma mark - Dark Shades

#if UIKIT_DEFINE_AS_PROPERTIES
/**
 *  Returns a flat color object whose HSB values are 0.00, 0.00, 0.15 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatBlackDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.62, 0.56, 0.51 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatBlueDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.07, 0.45, 0.31 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatBrownDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.07, 0.34, 0.56 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatCoffeeDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.38, 0.44, 0.31 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatForestGreenDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.51, 0.10, 0.55 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatGrayDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.40, 0.78, 0.68 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatGreenDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.21, 0.81, 0.69 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatLimeDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.78, 0.61, 0.68 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatMagentaDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.01, 0.68, 0.40 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatMaroonDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.47, 0.86, 0.63 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatMintDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.58, 0.45, 0.31 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatNavyBlueDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.07, 1.00, 0.83 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatOrangeDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.91, 0.57, 0.83 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatPinkDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.83, 0.46, 0.31 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatPlumDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.62, 0.28, 0.84 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatPowderBlueDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.70, 0.56, 0.64 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatPurpleDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.02, 0.78, 0.75 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatRedDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.12, 0.30, 0.84 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatSandDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.57, 0.78, 0.73 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatSkyBlueDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.54, 0.54, 0.45 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatTealDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.99, 0.61, 0.85 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatWatermelonDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.57, 0.05, 0.78 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatWhiteDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.11, 1.00, 1.00 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
@property(class, nonatomic, readonly) UIColor *flatYellowDarkColor;
#else

/**
 *  Returns a flat color object whose HSB values are 0.00, 0.00, 0.15 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatBlackDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.62, 0.56, 0.51 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatBlueDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.07, 0.45, 0.31 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatBrownDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.07, 0.34, 0.56 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatCoffeeDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.38, 0.44, 0.31 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatForestGreenDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.51, 0.10, 0.55 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatGrayDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.40, 0.78, 0.68 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatGreenDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.21, 0.81, 0.69 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatLimeDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.78, 0.61, 0.68 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatMagentaDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.01, 0.68, 0.40 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatMaroonDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.47, 0.86, 0.63 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatMintDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.58, 0.45, 0.31 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatNavyBlueDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.07, 1.00, 0.83 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatOrangeDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.91, 0.57, 0.83 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatPinkDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.83, 0.46, 0.31 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatPlumDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.62, 0.28, 0.84 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatPowderBlueDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.70, 0.56, 0.64 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatPurpleDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.02, 0.78, 0.75 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatRedDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.12, 0.30, 0.84 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatSandDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.57, 0.78, 0.73 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatSkyBlueDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.54, 0.54, 0.45 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatTealDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.99, 0.61, 0.85 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatWatermelonDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.57, 0.05, 0.78 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatWhiteDarkColor;

/**
 *  Returns a flat color object whose HSB values are 0.11, 1.00, 1.00 and whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 */
+ (UIColor *)flatYellowDarkColor;
#endif

#pragma mark - Randomizing Colors
#if UIKIT_DEFINE_AS_PROPERTIES
/**
 *  Returns a randomly generated flat color object whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 *
 *  @since 1.0
 */

@property(class, nonatomic, readonly) UIColor *randomFlatColor;
#else
/**
 *  Returns a randomly generated flat color object whose alpha value is 1.0.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 *
 *  @since 1.0
 */

+ (UIColor *)randomFlatColor;
#endif

/**
 *  @author Vicc Alexander
 *
 *  Returns a randomly generated flat color object NOT found in the specified array.
 *
 *  @param excludedColors An array specifying which colors NOT to return.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 *
 *  @since 2.1.0
 */
+ (UIColor *)colorWithRandomFlatColorExcludingColorsInArray:(NSArray<UIColor *> * _Nonnull)colors;

/**
 *  @author Vicc Alexander
 *
 *  Returns a randomly generated color object found in the specified array.
 *
 *  @param colors An array specifying which colors to return.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 *
 *  @since 2.1.0
 */
+ (UIColor * _Nullable)colorWithRandomColorInArray:(NSArray<UIColor *> * _Nonnull)colors;

/**
 *  Returns a randomly generated flat color object with an alpha value of 1.0 in either a light or dark shade.
 *
 *  @param shadeStyle Specifies whether the randomly generated flat color should be a light or dark shade.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 *
 *  @since 1.0
 */
+ (UIColor *)colorWithRandomFlatColorOfShadeStyle:(UIShadeStyle)shadeStyle;

/**
 *  Returns a randomly generated flat color object in either a light or dark shade.
 *
 *  @param shadeStyle Specifies whether the randomly generated flat color should be a light or dark shade.
 *  @param alpha      The opacity.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 *
 *  @since 2.0
 */
+ (UIColor *)colorWithRandomFlatColorOfShadeStyle:(UIShadeStyle)shadeStyle withAlpha:(CGFloat)alpha;

#pragma mark - Averaging a Color

/**
 *  Returns the average color generated by averaging the colors of a specified image.
 *
 *  @param image A specified @c UIImage.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 *
 *  @since 2.0
 */
+ (UIColor *)colorWithAverageColorFromImage:(UIImage *)image;

/**
 *  Returns the average color generated by averaging the colors of a specified image.
 *
 *  @param image A specified @c UIImage.
 *  @param alpha The opacity.
 *
 *  @return A flat @c UIColor object in the HSB colorspace.
 *
 *  @since 2.0
 */
+ (UIColor *)colorWithAverageColorFromImage:(UIImage *)image withAlpha:(CGFloat)alpha;

#pragma mark - Complementary Colors

/**
 *  Creates and returns a complementary flat color object 180 degrees away in the HSB colorspace from the specified color.
 *
 *  @param color The color whose complementary color is being requested.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 *
 *  @since 1.0
 */

+ (UIColor *)colorWithComplementaryFlatColorOf:(UIColor *)color;

/**
 *  Creates and returns a complementary flat color object 180 degrees away in the HSB colorspace from the specified color.
 *
 *  @param color The color whose complementary color is being requested.
 *  @param alpha The opacity.
 *
 *  @return A flat UIColor object in the HSB colorspace.
 *
 *  @since 2.0
 */

+ (UIColor *)colorWithComplementaryFlatColorOf:(UIColor *)color withAlpha:(CGFloat)alpha;

#pragma mark - Contrasting Colors

/**
 *  Creates and returns either a black or white color object depending on which contrasts more with a specified color.
 *
 *  @param color The specified color of the contrast color that is being requested.
 *  @param isFlat Pass YES to return flat color objects.
 *
 *  @return A UIColor object in the HSB colorspace.
 *
 *  @since 1.0
 */

+ (UIColor *)colorWithContrastingBlackOrWhiteColorOn:(UIColor *)backgroundColor isFlat:(BOOL)flat;

/**
 *  Creates and returns either a black or white color object depending on which contrasts more with a specified color.
 *
 *  @param color The specified color of the contrast color that is being requested.
 *  @param isFlat Pass YES to return flat color objects.
 *  @param alpha The opacity.
 *
 *  @return A UIColor object in the HSB colorspace.
 *
 *  @since 2.0
 */
+ (UIColor *)colorWithContrastingBlackOrWhiteColorOn:(UIColor *)backgroundColor isFlat:(BOOL)flat alpha:(CGFloat)alpha;

#pragma mark - Gradient Colors

/**
 *  Creates and returns a gradient as a color object with an alpha value of 1.0
 *
 *  @param gradientStyle Specifies the style and direction of the gradual blend between colors.
 *  @param frame The frame rectangle, which describes the view’s location and size in its superview’s coordinate system.
 *  @param colors An array of color objects used to create a gradient.
 *
 *  @return A @c UIColor object using colorWithPattern.
 *
 *  @since 2.0
 */
+ (UIColor *)colorWithGradientStyle:(UIGradientStyle)gradientStyle withFrame:(CGRect)frame andColors:(NSArray<UIColor *> * _Nonnull)colors;

#pragma mark - Colors from Hex Strings

/**
 *  Creates and returns a @c UIColor object based on the specified hex string.
 *
 *  @param string The hex string.
 *
 *  @return A @c UIColor object in the RGB colorspace.
 *
 *
 *  @since 2.0
 */
+ (UIColor * _Nullable)colorWithHexString:(NSString* _Nonnull)string;

/**
 *  Creates and returns a @c UIColor object based on the specified hex string.
 *
 *  @param string The hex string.
 *  @param alpha  The opacity.
 *
 *  @return A @c UIColor object in the RGB colorspace.
 *
 *
 *  @since 2.0
 */
+ (UIColor * _Nullable)colorWithHexString:(NSString * _Nonnull)string withAlpha:(CGFloat)alpha;

#pragma mark - Instance Methods

/**
 *  Creates and returns a flat color object closest to the specified color in the LAB colorspace.
 *
 *  @return A flat version of the specified @c UIColor.
 *
 *  @since 2.0
 */
- (UIColor *)flatten;

/**
 *  Creates and returns a darker shade of a specified color in the HSB space.
 *
 *  @param percentage The value with which to darken a specified color.
 *
 *  @return A @c UIColor object in the HSB space.
 *
 *  @since 2.0
 */
- (UIColor * _Nullable)darkenByPercentage:(CGFloat)percentage;

/**
 *  @author Vicc Alexander
 *
 *  Returns the hex string value for the specified color.
 *
 *  @return An @NSString object.
 *
 *  @since 2.1.0
 */
- (NSString *)hexValue;

/**
 *  Creates and returns a lighter shade of a specified color in the HSB space.
 *
 *  @param percentage The value with which to lighten a specified color.
 *
 *  @return A @c UIColor object in the HSB space.
 *
 *  @since 2.0
 */
- (UIColor * _Nullable)lightenByPercentage:(CGFloat)percentage;

#pragma mark - Deprecated Methods

/**
 *  Creates and returns a flat color object closest to the specified color in the LAB colorspace.
 *
 *  @param color The specified color of the flat color that is being requested.
 *
 *  @return A flat UIColor object in the RGB colorspace.
 *
 *  @since 1.0
 */
+ (UIColor *)colorWithFlatVersionOf:(UIColor *)color __attribute((deprecated(" Use -flatten: instead (First deprecated in Chameleon 2.0).")));


@end

NS_ASSUME_NONNULL_END
