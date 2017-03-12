<p align="center">
  <img src="http://i.imgur.com/BwqHhB4.png" alt="Chameleon by Vicc Alexander"/>
</p>

<p align="center">
    <img src="https://img.shields.io/cocoapods/dt/ChameleonFramework.svg?maxAge=86400" alt="Downloads"/>  
    <img src="https://img.shields.io/cocoapods/at/ChameleonFramework.svg?maxAge=86400" alt="Apps"/>
    <img src="https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat" alt="Platform: iOS 8+"/>
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-swift%203-4BC51D.svg?style=flat" alt="Language: Swift 3" /></a>
    <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
    <a href="https://cocoapods.org/pods/ChameleonFramework"><img src="https://cocoapod-badges.herokuapp.com/v/ChameleonFramework/badge.png" alt="CocoaPods compatible" /></a>
    <img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="License: MIT" /> <br><br>
</p>

## Swift 3

To use the Swift 3 version, add this to your Podfile (until 2.2 or higher is released):
```ruby
pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
```

## Introduction

**Chameleon** is a lightweight, yet powerful, color framework for iOS (Objective-C & Swift). It is built on the idea that software applications should function effortlessly while simultaneously maintaining their beautiful interfaces.

With Chameleon, you can easily stop tinkering with RGB values, wasting hours figuring out the right color combinations to use in your app, and worrying about whether your text will be readable on the various background colors of your app. 

### Features

<p align="center">
  <img src="http://i.imgur.com/lA4J37o.png" alt="Features"/>
</p>

### App Showcase

###### In an upcoming update we'll begin showcasing some of the best apps and companies making use of Chameleon. If you'd like to see your app featured in this section, make sure to add it [here](https://airtable.com/shrr1WK6dLQBZfXV0).

## Table of Contents
[● Product Features](https://github.com/ViccAlexander/Chameleon#-product-features)  
[● Requirements](https://github.com/ViccAlexander/Chameleon#%EF%B8%8F-requirements)  
[● License](https://github.com/ViccAlexander/Chameleon#-license)  
[● Contributions](https://github.com/ViccAlexander/Chameleon#-contributions)   
[● Documentation](https://github.com/ViccAlexander/Chameleon#-documentation)  
[● Storyboard Add-On](https://github.com/ViccAlexander/Chameleon#storyboard-add-on)  
[● Author](https://github.com/ViccAlexander/Chameleon#-author)   
[● To Do List](https://github.com/ViccAlexander/Chameleon#-to-do-list)  
[● Change Log](https://github.com/ViccAlexander/Chameleon#-change-log)  

## 🌟 Product Features

### 100% Flat & Gorgeous

Chameleon features over 24 hand-picked colors that come in both light and dark shades. 

<p align="center">
  <img src="http://i.imgur.com/wkGGWkN.png" alt="Swatches"/>
</p>

### Flat Color Schemes

Chameleon equips you with 3 different classes of flat color schemes that can be generated from a flat or non-flat color. *In the examples below, the white stars indicate the color used to generate the schemes.*

###### Analogous Flat Color Scheme

<p align="center">
  <img src="http://i.imgur.com/cPAkSWA.png" alt="Analogous Scheme"/>
</p>

###### Complementary Flat Color Scheme
<p align="center">
  <img src="http://i.imgur.com/kisXJsu.png" alt="Complementary Scheme"/>
</p>

###### Triadic Flat Color Scheme
<p align="center">
  <img src="http://i.imgur.com/Cy452jQ.png" alt="Triadic Scheme"/>
</p>

### Contrasting Text
With a plethora of color choices available for text, it's difficult to choose one that all users will appreciate and be able to read. Whether you're in doubt of your text and tint color choices, or afraid to let users customize their profile colors because it may disturb the legibility or usability of the app, you no longer have to worry. With Chameleon, you can ensure that all text stands out independent of the background color.

Oh... Chameleon works with the status bar as well. : )

<p align="center">
  <img src="http://s29.postimg.org/i1syd7bkn/Contrast.gif" alt="Status Bar"/>
</p>

### Themes ![Beta](http://i.imgur.com/JyYiUJq.png)

Chameleon now allows you easily theme your app with as little as **one line of code**. You can set a theme for all your views, and for specific views as well.

<p align="center">
  <img src="http://i.imgur.com/ypfqpIn.png" alt="Themes"/>
</p>

### Colors From Images 

Chameleon allows you to seamlessly extract non-flat or flat color schemes from images without hassle. You can also generate the average color from an image with ease. You can now mold the UI colors of a profile, or product based on an image!

<p align="center">
  <img src="http://i.imgur.com/6JjFzHo.png" alt="Colors from images"/>
</p>

### Gradient Colors
With iOS 7 & 8, Apple mainstreamed flat colors. Now, with the release of iOS 9, Chameleon strives to elevate the game once more. Say hello to gradient colors. Using one line of code, you can easily set any object's color properties to a gradient (background colors, text colors, tint colors, etc). Other features, like Chameleon's contrasting feature, can also be applied to create a seamless product. Experimentation is encouraged, and gutsiness is applauded!

<p align="center">
  <img src="http://i.imgur.com/7hTa5Pd.png" alt="Gradients"/>
</p>

![](http://i.imgur.com/2jN72eh.png)

### Xcode Quick Help Documentation

Chameleon's documentation, while written as clearly and concisely as possible may still render some slightly confused. But don't fret! Staying true to our vision of simplifying the entire color process, we added Xcode Quick Help's Documentation Support! Simply highlight a Chameleon method or tap it with three fingers to find out more about what it is and what it does!

<p align="center">
  <img src="http://i.imgur.com/p4KkQ9X.png" alt="Xcode Quick Help Documentation"/>
</p>
  
### Palettes

If you're like us and love to use storyboards, Chameleon's got you covered. We've provided you with a quick and easy way to access Chameleon colors right from Storyboard, and any other app that uses the color picker (i.e. TextEdit). In addition you can even import the palette directly into Photoshop and Sketch.

<p align="center">
  <img src="http://i.imgur.com/5lrB3BA.png" alt="Chameleon Palette"/>
</p>

<p align="center">
  <img src="http://i.imgur.com/QhhPFHY.gif" alt="Chameleon Palette"/>
</p>

## ⚠️ Requirements

* Objective-C or Swift
* Requires a minimum of iOS 7.0 for Objective-C (No active development for anything earlier, but may work with 6.0) and a minimum of iOS 8.0 for Swift.
* Requires Xcode 6.3 for use in any iOS Project

## 🔑 License
Chameleon is released and distributed under the terms and conditions of the [MIT license](https://github.com/ViccAlexander/Chameleon/blob/master/LICENSE.md).

## 👥 Contributions
If you run into problems, please open up an issue. We also actively welcome pull requests. By contributing to Chameleon you agree that your contributions will be licensed under its MIT license.

If you use Chameleon in your app we would love to hear about it! Drop Vicc a line on [twitter](http://twitter.com/viccsmind).

## 📗 Documentation
All methods, properties, and types available in Chameleon are documented below.   

#####Documentation Table of Contents  
[● Installation](https://github.com/ViccAlexander/Chameleon#installation)  
[● Palettes](https://github.com/ViccAlexander/Chameleon#palettes)  
[● Usage](https://github.com/ViccAlexander/Chameleon#usage)  
[● UIColor Methods](https://github.com/ViccAlexander/Chameleon#uicolor-methods)  
[● Colors From Images](https://github.com/ViccAlexander/Chameleon#colors-from-images)  
[● UIStatusBarStyle Methods](https://github.com/ViccAlexander/Chameleon#uistatusbarstyle-methods)  
[● Color Scheme Methods](https://github.com/ViccAlexander/Chameleon#color-schemes-methods)  
[● Theme Methods](https://github.com/ViccAlexander/Chameleon#theme-methods)  

###Installation

###### Note: Swift 3 version maintained in a separate branch until it's release.

####CocoaPods Installation
Chameleon is now available on [CocoaPods](http://cocoapods.org). Simply add the following to your project Podfile, and you'll be good to go.

######Objective-C
```ruby
use_frameworks!

pod 'ChameleonFramework'
```
######Swift
```ruby
use_frameworks!

pod 'ChameleonFramework/Swift'
```

=======
####Carthage Installation
Add this to your Cartfile:
```ruby
github "ViccAlexander/Chameleon"
```

=======
####Manual Installation
If you rather install this framework manually, just drag and drop the Chameleon folder into your project, and make sure you check the following boxes. Note: Don't forget to manually import the *QuartzCore* & *CoreGraphics* framework if you plan on using gradient colors!

<p align="center">
  <img src="http://i.imgur.com/gDXaF5F.png" alt="Manual Installation"/>
</p>

If you're working with Swift and are manually installing Chameleon, there's an additional step. Make sure to download and drag the following file, [ChameleonShorthand.swift](https://github.com/ViccAlexander/Chameleon/blob/master/Pod/Classes/Swift/ChameleonShorthand.swift), into your project, and you'll be good to go.

####Palettes
##### Storyboard Add-On
Using Chameleon's awesome palette in Storyboard is easy! Simply download and install [Chameleon Palette](https://github.com/ViccAlexander/Chameleon/blob/master/Extras/Chameleon.dmg?raw=true).

Once installed, make sure to restart Xcode. You'll find all of Chameleon's colors in the Palette Color Picker whenever they're needed! :)

<p align="center">
  <img src="http://i.imgur.com/XqpFUSt.png" alt="Chameleon Palette"/>
</p>

<p align="center">
  <img src="http://i.imgur.com/QhhPFHY.gif" alt="Chameleon Palette"/>
</p>

##### Photoshop Add-On
Using Chameleon's awesome palette in Sketch is easy! Simply download and install [Photoshop Palette](https://github.com/ViccAlexander/Chameleon/blob/master/Extras/Chameleon_Photoshop.aco?raw=true).

##### Sketch Add-On
Using Chameleon's awesome palette in Sketch is easy! Simply download and install [Sketch Palette](https://github.com/ViccAlexander/Chameleon/blob/master/Extras/Chameleon.sketchpalette?raw=true).

###Usage
To use the myriad of features in Chameleon, include the following import:

###### If you installed Chameleon using CocoaPods:

######Objective-C

``` objective-c
#import <ChameleonFramework/Chameleon.h>
```

######Swift:
``` swift
import ChameleonFramework
```

###### If you installed Chameleon using Carthage:

``` swift
import Chameleon
```

###### If you installed Chameleon manually:
``` objective-c
#import "Chameleon.h"
```
###UIColor Methods
[● Flat Colors](https://github.com/ViccAlexander/Chameleon#flat-colors)   
[● Random Colors](https://github.com/ViccAlexander/Chameleon#random-colors)  
[● Complementary Colors](https://github.com/ViccAlexander/Chameleon#complementary-colors)  
[● Contrasting Colors](https://github.com/ViccAlexander/Chameleon#contrasting-colors)  
[● Flattening Non-Flat Colors](https://github.com/ViccAlexander/Chameleon#flattening-non-flat-colors)  
[● Gradient Colors](https://github.com/ViccAlexander/Chameleon#gradient-colors-1)   
[● Hex Colors](https://github.com/ViccAlexander/Chameleon#hex-colors-)  
[● Lighter & Darker Colors](https://github.com/ViccAlexander/Chameleon#lighter-and-darker-colors-)

####Flat Colors
Using a flat color is as easy as adding any other color in your app (if not easier). For example, to set a view's background property to a flat color with a dark shade, you simply have to do the following:

#####Normal Convention:

######Objective-C
``` objective-c
self.view.backgroundColor = [UIColor flatGreenColorDark];
```
######Swift
``` swift
view.backgroundColor = UIColor.flatGreenDark
```

#####Chameleon Shorthand:

######Objective-C
``` objective-c
self.view.backgroundColor = FlatGreenDark;
```
######Swift
``` swift
view.backgroundColor = FlatGreenDark()
```

Setting the color for a light shade is the same, except without adding the *Dark* suffix. (By default, all colors without a *Dark* suffix are light shades). For example:

#####Normal Convention:
######Objective-C
``` objective-c
self.view.backgroundColor = [UIColor flatGreenColor];
```
######Swift
``` swift
view.backgroundColor = UIColor.flatGreen
```

#####Chameleon Shorthand:

######Objective-C
``` objective-c
self.view.backgroundColor = FlatGreen;
```
######Swift
``` swift
view.backgroundColor = FlatGreen()
```

####Random Colors
There are four ways to generate a random flat color. If you have no preference as to whether you want a light shade or a dark shade, you can do the following:

#####Normal Convention:
######Objective-C
``` objective-c
self.view.backgroundColor = [UIColor randomFlatColor];
```
######Swift
``` swift
view.backgroundColor = UIColor.randomFlat()
```

#####Chameleon Shorthand:
###### Objective-C
``` objective-c
self.view.backgroundColor = RandomFlatColor;
```

######Swift
``` swift
view.backgroundColor = RandomFlatColor()
```

Otherwise, you can perform the following method call to specify whether it should return either a light or dark shade:

#####Normal Convention:
######Objective-C
``` objective-c
[UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
```

######Swift
``` swift
UIColor(randomFlatColorOfShadeStyle:.Light)
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
RandomFlatColorWithShade(UIShadeStyleLight);
```
######Swift
``` swift
RandomFlatColorWithShade(.Light)
```

**UIShadeStyles:**  
- `UIShadeStyleLight` (`UIShadeStyle.Light` in Swift)
- `UIShadeStyleDark` (`UIShadeStyle.Dark` in Swift)

##### Choosing A Random Color From a List of Colors ![New](http://i.imgur.com/BX3b9ES.png)

If you need to be a bit more selective and only display a random color from a set list of colors, you can use the following method:

#####Normal Convention:
######Objective-C
``` objective-c
[UIColor colorWithRandomColorInArray:@[FlatWhite, FlatRed, FlatBlue]];
```

######Swift
``` swift
TBA
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
RandomFlatColorInArray(@[FlatWhite, FlatRed, FlatBlue]) 
```
######Swift
``` swift
TBA
```

##### Choosing A Random Flat Color But Excluding A Few ![New](http://i.imgur.com/BX3b9ES.png)

Last but certainly not least, you can also choose form the list of random colors and exclude the ones you don't want. For example say you want to randomly select a flat color for a user's profile, but don't want to use any blacks, grays, or whites. You can simply do:

#####Normal Convention:
######Objective-C
``` objective-c
[UIColor colorWithRandomFlatColorExcludingColorsInArray:@[FlatBlack, FlatBlackDark, FlatGray, FlatGrayDark, FlatWhite, FlatWhiteDark]];
```

######Swift
``` swift
TBA
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
RandomFlatColorExcluding(@[FlatBlack, FlatBlackDark, FlatGray, FlatGrayDark, FlatWhite, FlatWhiteDark]) 
```
######Swift
``` swift
TBA
```

####Complementary Colors
To generate a complementary color, perform the following method call, remembering to specify the color whose complement you want:

#####Normal Convention:
######Objective-C
``` objective-c
[UIColor colorWithComplementaryFlatColorOf:(UIColor *)someUIColor];
```

######Swift
``` swift
UIColor(complementaryFlatColorOf:someUIColor)
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
ComplementaryFlatColorOf(color);
```

######Swift
``` swift
ComplementaryFlatColorOf(color)
```

####Contrasting Colors
The contrasting color feature returns either a dark color a light color depending on what the Chameleon algorithm believes is a better choice. You can specify whether the dark or light colors are flat: *`([UIColor flatWhiteColor]` & `[UIColor flatBlackColorDark]`)* or non-flat *(`[UIColor whiteColor]` & `[UIColor blackColor]`).*

If you're trying to set a `UILabel's textColor` property, make sure you provide the `UILabel's backgroundColor`. If your label has a clear `backgroundColor`, just provide the `backgroundColor` property of the object directly behind the `UILabel`.

Here's an example:

#####Normal Convention:
######Objective-C
``` objective-c
[UIColor colorWithContrastingBlackOrWhiteColorOn:(UIColor *)backgroundColor isFlat:(BOOL)flat];
```

######Swift
``` swift
UIColor(contrastingBlackOrWhiteColorOn:UIColor!, isFlat:Bool)
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
ContrastColor(backgroundColor, isFlat);
```

######Swift
``` swift
ContrastColor(backgroundColor, isFlat)
```

####Flattening Non-Flat Colors
As mentioned previously, this feature is unique to Chameleon. While this feature is in its early stages of operation and can be improved, it is accurate in finding the nearest flat version of any color in the spectrum, and very simple to use:

#####Normal Convention:
######Objective-C
``` objective-c
[(UIColor *)color flatten];
```

######Swift
``` swift
UIColor.pink.flatten()
```

#### Gradient Colors
Using a gradient to color an object usually requires a couple of lines of code plus many more lines to superimpose smart contrasting text. Thankfully, Chameleon takes care of that for you. We've introduced a new way to have multicolored objects, and that's with gradients!

#####Gradient Styles
Chameleon provides three simple gradient styles. Gradients can be created from any number of colors you desire as long as at least two colors are provided. Don't forget that the contrasting text feature is also compatible with gradient colors!

**UIGradientStyles:**
* `UIGradientStyleLeftToRight` (UIGradientStyle.LeftToRight in Swift)
* `UIGradientStyleTopToBottom` (UIGradientStyle.TopToBottom in Swift)
* `UIGradientStyleRadial` (UIGradientStyle.Radial in Swift)

#####Normal Convention:
######Objective-C
``` objective-c
[UIColor colorWithGradientStyle:(UIGradientStyle)gradientStyle withFrame:(CGRect)frame andColors:(NSArray<UIColor *> *)colors];
```

######Swift
``` swift
UIColor(gradientStyle:UIGradientStyle, withFrame:CGRect, andColors:[UIColor])
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
GradientColor(gradientStyle, frame, colors);
```

######Swift
``` swift
GradientColor(gradientStyle, frame, colors)
```

**Objective-C Note**: If you use the Chameleon Shorthand, and use the `NSArray` literal ```@[]``` to set the array of colors, make sure you add parenthesis around it, or else you'll get an error.

Note: `UIGradientStyleRadial` only uses a maximum of 2 colors at the moment. So if more colors are provided, they will not show.

#### Hex Colors

One of the most requested features, *hex colors*, is now available. You can simply provide a hex string with or without a *#* sign:

#####Normal Convention:
######Objective-C
``` objective-c
[UIColor colorWithHexString:(NSString *)string];
```

######Swift
``` swift
UIColor(hexString:string)
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
HexColor(hexString)
```

######Swift
``` swift
HexColor(hexString)
```
#### Hex Values ![New](http://i.imgur.com/BX3b9ES.png)

Retrieving the `hexValue` of a UIColor is just as easy.

######Objective-C
``` objective-c
[FlatGreen hexValue]; //Returns @"2ecc71"
```

######Swift
``` swift
FlatGreen.hexValue //Returns @"2ecc71"
```

#### Lighter and Darker Colors

Sometimes all you need is a color a shade lighter or a shade darker. Well for those rare, but crucial moments, Chameleon's got you covered. You can now lighten any color the following way:

#####Normal Convention:
######Objective-C
``` objective-c
[color lightenByPercentage:(CGFloat)percentage];
```

######Swift
``` swift
color.lightenByPercentage(percentage: CGFloat)
```

You can also generate a darker version of a color:

#####Normal Convention:
######Objective-C
``` objective-c
[color darkenByPercentage:(CGFloat)percentage];
```

######Swift
``` swift
color.darkenByPercentage(percentage: CGFloat)
```

### Colors From Images

Chameleon now supports the extraction of colors from images. You can either generate both flat and non-flat color schemes from an image, or easily extract the average color.

To generate a color scheme simply do the following:
#####Normal Convention:
######Objective-C
``` objective-c
[NSArray arrayOfColorsFromImage:(UIImage *)image withFlatScheme:(BOOL)flatScheme];
```

######Swift (**Array extension missing**)
``` swift
NSArray(ofColorsFromImage: UIImage, withFlatScheme: Bool)
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
ColorsFromImage(image, isFlatScheme)
```

######Swift
``` swift
ColorsFromImage(image, isFlatScheme)
```

To extract the average color from an image, you can also do:
#####Normal Convention:
######Objective-C
``` objective-c
[UIColor colorWithAverageColorFromImage:(UIImage *)image];
```

######Swift
``` swift
UIColor(averageColorFromImage: UIImage)
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
AverageColorFromImage(image)
```

######Swift
``` swift
AverageColorFromImage(image)
```

###UIStatusBarStyle Methods
####Contrasting UIStatusBarStyle
Many apps on the market, even the most popular ones, overlook this aspect of a beautiful app: the status bar style. Chameleon has done something no other framework has... it has created a new status bar style: `UIStatusBarStyleContrast`. Whether you have a `ViewController` embedded in a `NavigationController`, or not, you can do the following:

#####Normal Convention:
######Objective-C
``` objective-c
[self setStatusBarStyle:UIStatusBarStyleContrast];
```

######Swift
``` swift
self.setStatusBarStyle(UIStatusBarStyleContrast)
```
######**Note**: Make sure that the key *View controller-based status bar appearance* in **Info.plist** is set to `YES`.

###Color Schemes Methods
######**Note**: *Due to the limited number of flat colors currently available, color schemes may return results that reuse certain flat colors. Because of this redundancy, we have provided an option to return either a flat color scheme or a non-flat color scheme until more flat colors are added to the inventory.*

The initial color can be either a non-flat color or flat color. Chameleon will return an `NSArray` of 5 `UIColors` in which the original color will be the third object of the scheme. This allows for Chameleon to designate the colors of the color scheme (2 colors counter-clockwise and 2 clockwise from the initial color), and thus, the chosen colors are aligned specifically in that order. 

####Analogous Color Scheme
An analogous color scheme uses three adjacent colors on the color wheel. According to Wikipedia, it’s best used with either warm or cool colors, creating a cohesive collection with certain temperature qualities as well as proper color harmony; however, this particular scheme lacks contrast and is less vibrant than complementary schemes. Within the scheme, choose one color to dominate and two to support. The remaining two colors should be used (along with black, white or gray) as accents.

####Complementary Color Scheme
A complementary color scheme uses opposite colors on the color wheel. To put into slightly more technical terms, they are two colors that, when combined, produce a neutral color. Complementary colors are tricky to use extensively, but work well when you want a point of emphasis. Complementary colors are generally not favorable to use for text. 

####Triadic Color Scheme
A triadic scheme uses evenly spaced colors on the color wheel. The colors tend to be richly vivid and offer a higher degree of contrast while, at the same time, retain color harmony. Let one color dominate and use the two others for accent.

####Getting Colors in a Color Scheme
To retrieve an array of colors, first make sure to initialize an NSMutableArray (in case you want to use the same array to replace with different colors later):

#####Normal Convention:
######Objective-C
``` objective-c
NSMutableArray *colorArray = [NSMutableArray alloc] initWithArray:[NSArray arrayOfColorsWithColorScheme:(ColorScheme)colorScheme 
                                                                                                    with:(UIColor *)color 
                                                                                             flatScheme:(BOOL)isFlatScheme]];
```

######Swift
``` swift
var colorArray = NSArray(ofColorsWithColorScheme:ColorScheme, with:UIColor!, flatScheme:Bool)
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
NSMutableArray *colorArray = [[NSMutableArray alloc] initWithArray:ColorScheme(colorSchemeType, color, isFlatScheme)];
```

######Swift
``` swift
var colorArray = ColorSchemeOf(colorSchemeType, color, isFlatScheme)
```

#####Example:
Assuming you want to generate an analogous color scheme for the light shade of Flat Red, perform the following method call:

#####Normal Convention:
######Objective-C
``` objective-c
NSMutableArray *colorArray = [NSMutableArray alloc] initWithArray:[NSArray arrayOfColorsWithColorScheme:ColorSchemeAnalogous
                                                                                                    with:[UIColor flatRedColor] 
                                                                                             flatScheme:YES]];
```

######Swift
``` swift
var colorArray = NSArray(ofColorsWithColorScheme:ColorScheme.Analogous, with:UIColor.flatRed, flatScheme:true)
```

#####Chameleon Shorthand:
######Objective-C
``` objective-c
NSMutableArray *colorArray = [[NSMutableArray alloc] initWithArray:ColorScheme(ColorSchemeAnalogous, FlatRed, YES)];
```

######Swift
``` swift
var colorArray = ColorSchemeOf(ColorScheme.Analogous, FlatRed(), true)
```  

You can then retrieve each individual color the same way you would normally retrieve any object from an array:

######Objective-C
```objective-c
UIColor *firstColor = colorArray[0];
```

######Swift
``` swift
var firstColor = colorArray[0] as! UIColor
```  

###Theme Methods

With Chameleon, you can now specify a global color theme with simply one line of code (It even takes care of dealing with the status bar style as well)! Here's one of three methods to get you started. `ContentStyle` allows you to decide whether text and a few other elements should be white, black, or whichever contrasts more over any UI element's `backgroundColor`. 

To set a global theme, you can do the following in your app delegate:

#####Normal Convention:
######Objective-C
``` objective-c
[Chameleon setGlobalThemeUsingPrimaryColor:(UIColor *)color withContentStyle:(UIContentStyle)contentStyle];
```

But what if you want a different theme for a specific `UIViewController?` No problem, Chameleon allows you to override the global theme in any `UIViewController` and `UINavigationController`, by simply doing the following:

#####Normal Convention:
######Objective-C
```objective-c
//This would go in the controller you specifically want to theme differently
[self setThemeUsingPrimaryColor:FlatMint withSecondaryColor:FlatBlue andContentStyle:UIContentStyleContrast];
```

###### **Note:** In order for the status bar style to automatically be set using a theme, you need to make sure that the *View controller-based status bar appearance* key in **Info.plist** is set to `NO`.

#### Navigation Bar Hairline

![No Hairline](http://i.imgur.com/tjwx53y.png)

As of `2.0.3` the navigation bar hairline view is no longer hidden by default. However, if you're seeking a true flat look (like the image above), you can hide the hairline at the bottom of the navigation bar by doing the following: 

######Objective-C
```objective-c
[self.navigationController setHidesNavigationBarHairline:YES];

//or

self.navigationController.hidesNavigationBarHairline = YES;
```

######Swift
```swift
self.navigationController?.hidesNavigationBarHairline = true
``` 

## 👑 Author
Chameleon was developed by **Vicc Alexander** [(@ViccsMind)](https://twitter.com/viccsmind) in 2014 using Objective-C. In 2015, full Swift support was implemented by [@Bre7](https://github.com/bre7). Currently, it is being maintained by both [@ViccAlexander](https://github.com/ViccAlexander) and [@Bre7](https://github.com/bre7).

## 📝 To Do List 
* ~~CocoaPods Support~~ ![1.0.1](http://i.imgur.com/8Li5aRR.png)  
* ~~Table of Contents~~ ![1.0.1](http://i.imgur.com/8Li5aRR.png)  
* ~~Storyboard Color Picker Add-On~~ ![1.1.0](http://i.imgur.com/Py4QvaK.png)  
* ~~Xcode In-App Documentation~~ ![1.1.0](http://i.imgur.com/Py4QvaK.png)  
* ~~Switch from RGB values over to HSB and LAB~~ ![1.1.0](http://i.imgur.com/Py4QvaK.png)  
* ~~Gradient Colors~~ ![1.1.0](http://i.imgur.com/Py4QvaK.png)  
* ~~Update GradientStyle & ShadeStyle Syntax~~ ![1.1.1](http://i.imgur.com/AHxj8Rb.png)  
* ~~Add Radial Gradient Support~~ ![1.1.1](http://i.imgur.com/AHxj8Rb.png)  
* ~~Fix Swift Conflict with `initWithArray:for:flatScheme:` method~~  ![1.1.12](http://i.imgur.com/7NrZ7yx.png)  
* ~~Swift Support~~ ![1.1.3](http://i.imgur.com/WgpBlLo.png)     
* ~~Color Scheme From Images~~ ![2.0.0](http://i.imgur.com/HdE8kjQ.png)  
* ~~UIAppearance Convenience Methods~~  ![2.0.0](http://i.imgur.com/HdE8kjQ.png)  
* ~~Add option to hide `NavigationBar` hairline~~ ![2.0.3](http://i.imgur.com/DmlOKPJ.png)
* ~~Add support for App Extensions hairline~~ ![2.2.0](http://i.imgur.com/z6575IT.png)
* Add Swift Support for Random Colors
* Allow Gradient Colors to Adapt To Frame Changes

## 📄 Change Log

### See [Changelog.md](https://github.com/ViccAlexander/Chameleon/blob/master/CHANGELOG.md) 👀

