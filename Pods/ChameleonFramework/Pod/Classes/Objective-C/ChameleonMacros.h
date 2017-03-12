
//  ChameleonMacros.h

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

#import "UIColor+Chameleon.h"

#pragma mark - Light Shades Shorthand

#define FlatBlack [UIColor flatBlackColor]
#define FlatBlue [UIColor flatBlueColor]
#define FlatBrown [UIColor flatBrownColor]
#define FlatCoffee [UIColor flatCoffeeColor]
#define FlatForestGreen [UIColor flatForestGreenColor]
#define FlatGray [UIColor flatGrayColor]
#define FlatGreen [UIColor flatGreenColor]
#define FlatLime [UIColor flatLimeColor]
#define FlatMagenta [UIColor flatMagentaColor]
#define FlatMaroon [UIColor flatMaroonColor]
#define FlatMint [UIColor flatMintColor]
#define FlatNavyBlue [UIColor flatNavyBlueColor]
#define FlatOrange [UIColor flatOrangeColor]
#define FlatPink [UIColor flatPinkColor]
#define FlatPlum [UIColor flatPlumColor]
#define FlatPowderBlue [UIColor flatPowderBlueColor]
#define FlatPurple [UIColor flatPurpleColor]
#define FlatRed [UIColor flatRedColor]
#define FlatSand [UIColor flatSandColor]
#define FlatSkyBlue [UIColor flatSkyBlueColor]
#define FlatTeal [UIColor flatTealColor]
#define FlatWatermelon [UIColor flatWatermelonColor]
#define FlatWhite [UIColor flatWhiteColor]
#define FlatYellow [UIColor flatYellowColor]

// ---------------------------------------------------

#pragma mark - Dark Shades Shorthand

#define FlatBlackDark [UIColor flatBlackDarkColor]
#define FlatBlueDark [UIColor flatBlueDarkColor]
#define FlatBrownDark [UIColor flatBrownDarkColor]
#define FlatCoffeeDark [UIColor flatCoffeeDarkColor]
#define FlatForestGreenDark [UIColor flatForestGreenDarkColor]
#define FlatGrayDark [UIColor flatGrayDarkColor]
#define FlatGreenDark [UIColor flatGreenDarkColor]
#define FlatLimeDark [UIColor flatLimeDarkColor]
#define FlatMagentaDark [UIColor flatMagentaDarkColor]
#define FlatMaroonDark [UIColor flatMaroonDarkColor]
#define FlatMintDark [UIColor flatMintDarkColor]
#define FlatNavyBlueDark [UIColor flatNavyBlueDarkColor]
#define FlatOrangeDark [UIColor flatOrangeDarkColor]
#define FlatPinkDark [UIColor flatPinkDarkColor]
#define FlatPlumDark [UIColor flatPlumDarkColor]
#define FlatPowderBlueDark [UIColor flatPowderBlueDarkColor]
#define FlatPurpleDark [UIColor flatPurpleDarkColor]
#define FlatRedDark [UIColor flatRedDarkColor]
#define FlatSandDark [UIColor flatSandDarkColor]
#define FlatSkyBlueDark [UIColor flatSkyBlueDarkColor]
#define FlatTealDark [UIColor flatTealDarkColor]
#define FlatWatermelonDark [UIColor flatWatermelonDarkColor]
#define FlatWhiteDark [UIColor flatWhiteDarkColor]
#define FlatYellowDark [UIColor flatYellowDarkColor]

// ---------------------------------------------------

#pragma mark - Special Colors Shorthand

#define RandomFlatColor [UIColor randomFlatColor]
#define ClearColor [UIColor clearColor]

// ---------------------------------------------------

#pragma mark - UIColor Methods Shorthand

#define AverageColorFromImage(image) [UIColor colorWithAverageColorFromImage:image]
#define AverageColorFromImageWithAlpha(image, alpha) [UIColor colorWithAverageColorFromImage:image withAlpha:alpha]

#define ComplementaryFlatColor(color) [UIColor colorWithComplementaryFlatColorOf:color]
#define ComplementaryFlatColorWithAlpha(color, alpha) [UIColor colorWithComplementaryFlatColorOf:color withAlpha:alpha]

#define ContrastColor(backgroundColor, returnFlat) [UIColor colorWithContrastingBlackOrWhiteColorOn:backgroundColor isFlat:returnFlat]
#define ContrastColorWithAlpha(backgroundColor, returnFlat, alpha) [UIColor colorWithContrastingBlackOrWhiteColorOn:backgroundColor isFlat:returnFlat alpha:alpha]

#define GradientColor(gradientStyle, frame, colors) [UIColor colorWithGradientStyle:gradientStyle withFrame:frame andColors:colors]

#define HexColor(hexString) [UIColor colorWithHexString:hexString]
#define HexColorWithAlpha(hexString, alpha) [UIColor colorWithHexString:hexString withAlpha:alpha]

#define RandomFlatColorInArray(colors) [UIColor colorWithRandomColorInArray:colors]
#define RandomFlatColorExcluding(colors) [UIColor colorWithRandomFlatColorExcludingColorsInArray:colors];
#define RandomFlatColorWithShade(shade) [UIColor colorWithRandomFlatColorOfShadeStyle:shade]
#define RandomFlatColorWithShadeAndAlpha(shade, alpha) [UIColor colorWithRandomFlatColorOfShadeStyle:shade withAlpha:alpha]

// ---------------------------------------------------

#pragma mark - NSArray Shorthand

#define ColorsWithScheme(colorSchemeType, color, isFlatScheme) [NSArray arrayOfColorsWithColorScheme:colorSchemeType usingColor:color withFlatScheme:isFlatScheme]
#define ColorsFromImage(image, isFlatScheme) [NSArray arrayOfColorsFromImage:image withFlatScheme:isFlatScheme]

