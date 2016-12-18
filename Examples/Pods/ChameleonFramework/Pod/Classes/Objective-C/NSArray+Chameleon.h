
//  NSArray+Chameleon.h

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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - Enums

/**
 *  Color schemes with which to select colors using a specified color.
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, ColorScheme){
    /**
     *  Analogous color schemes use colors that are next to each other on the color wheel. They usually match well and create serene and comfortable designs. Analogous color schemes are often found in nature and are harmonious and pleasing to the eye. Make sure you have enough contrast when choosing an analogous color scheme. Choose one color to dominate, a second to support. The third color is used (along with black, white or gray) as an accent.
     *
     *  @since 1.0
     */
    ColorSchemeAnalogous,
    /**
     *  A triadic color scheme uses colors that are evenly spaced around the color wheel. Triadic color harmonies tend to be quite vibrant, even if you use pale or unsaturated versions of your hues. To use a triadic harmony successfully, the colors should be carefully balanced - let one color dominate and use the two others for accent.
     *
     *  @since 1.0
     */
    ColorSchemeTriadic,
    /**
     *  Colors that are opposite each other on the color wheel are considered to be complementary colors (example: red and green). The high contrast of complementary colors creates a vibrant look especially when used at full saturation. This color scheme must be managed well so it is not jarring. Complementary colors are tricky to use in large doses, but work well when you want something to stand out. Complementary colors are really bad for text.
     *
     *  @since 1.0
     */
    ColorSchemeComplementary
};

@interface NSArray (Chameleon)

#pragma mark - Generating Color Schemes

/**
 *  Generates and creates an array of 5 color objects in the HSB colorspace from the specified color.
 *
 *  @param colorScheme  The color scheme with which to select colors using a specified color.
 *  @param color        The specified color which the color scheme is built around.
 *  @param isFlatScheme Pass YES to return flat color objects.
 *
 *  @return An array of 5 color objects in the HSB colorspace.
 *
 *  @since 2.0
 */
+ (NSArray *)arrayOfColorsWithColorScheme:(ColorScheme)colorScheme
                               usingColor:(UIColor *)color
                           withFlatScheme:(BOOL)isFlatScheme;

/**
 *  Generates and creates an array of 5 color objects in the HSB colorspace that appear most often in a specified image.
 *
 *  @param image        The specified image which the color scheme is built around.
 *  @param isFlatScheme Pass YES to return flat color objects.
 *
 *  @return An array of 5 color objects in the HSB colorspace.
 *
 *  @since 2.0
 */
+ (NSArray *)arrayOfColorsFromImage:(UIImage *)image
                     withFlatScheme:(BOOL)isFlatScheme;

#pragma mark - Deprecated Methods

/**
 *  Generates and creates an array of 5 color objects in the HSB colorspace from the specified color.
 *
 *  @param colorScheme  The color scheme with which to select colors using a specified color.
 *
 *  @param color        The specified color which the color scheme is built around.
 *
 *  @param isFlatScheme Pass YES to return flat color objects.
 *
 *  @return An array of 5 color objects in the HSB colorspace.
 *
  *  @since 1.1.2
 */
+ (NSArray *)arrayOfColorsWithColorScheme:(ColorScheme)colorScheme
                                     with:(UIColor *)color
                               flatScheme:(BOOL)isFlatScheme __attribute((deprecated(" Use -arrayOfColorsWithColorScheme:usingColor:withFlatScheme: instead (First deprecated in Chameleon 2.0).")));

@end
