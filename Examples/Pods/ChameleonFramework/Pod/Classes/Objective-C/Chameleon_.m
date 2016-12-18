//
//  ChameleonInternal.m
//  Chameleon
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import "Chameleon_.h"
#import "UILabel+Chameleon.h"
#import "UIButton+Chameleon.h"
#import "UIAppearance+Swift.h"

@implementation Chameleon

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

+ (void)setGlobalThemeUsingPrimaryColor:(UIColor *)primaryColor
                       withContentStyle:(UIContentStyle)contentStyle {
    
    if (contentStyle == UIContentStyleContrast) {
        
        if ([ContrastColor(primaryColor, YES) isEqual:FlatWhite]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
        
    } else if (contentStyle == UIContentStyleLight) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    } else {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [[self class] customizeBarButtonItemWithPrimaryColor:primaryColor contentStyle:contentStyle];
    [[self class] customizeButtonWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeNavigationBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizePageControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeProgressViewWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSearchBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSegmentedControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSliderWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeStepperWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSwitchWithPrimaryColor:primaryColor];
    [[self class] customizeTabBarWithBarTintColor:FlatWhite andTintColor:primaryColor];
    [[self class] customizeToolbarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeImagePickerControllerWithPrimaryColor:primaryColor withContentStyle:contentStyle];
}


+ (void)setGlobalThemeUsingPrimaryColor:(UIColor *)primaryColor
                     withSecondaryColor:(UIColor *)secondaryColor
                        andContentStyle:(UIContentStyle)contentStyle {
    
    if (contentStyle == UIContentStyleContrast) {
        
        if ([ContrastColor(primaryColor, YES) isEqual:FlatWhite]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
        
    } else if (contentStyle == UIContentStyleLight) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    } else {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [[self class] customizeBarButtonItemWithPrimaryColor:primaryColor contentStyle:contentStyle];
    [[self class] customizeButtonWithPrimaryColor:primaryColor secondaryColor:secondaryColor withContentStyle:contentStyle];
    [[self class] customizeNavigationBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizePageControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeProgressViewWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeSearchBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSegmentedControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSliderWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeStepperWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSwitchWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeTabBarWithBarTintColor:FlatWhite andTintColor:primaryColor];
    [[self class] customizeToolbarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeImagePickerControllerWithPrimaryColor:primaryColor withContentStyle:contentStyle];
}

+ (void)setGlobalThemeUsingPrimaryColor:(UIColor *)primaryColor
                     withSecondaryColor:(UIColor *)secondaryColor
                          usingFontName:(NSString *)fontName
                        andContentStyle:(UIContentStyle)contentStyle {
    
    if (contentStyle == UIContentStyleContrast) {
        
        if ([ContrastColor(primaryColor, YES) isEqual:FlatWhite]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
        
    } else if (contentStyle == UIContentStyleLight) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    } else {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [[UILabel appearance] setSubstituteFontName:fontName];
    [[UIButton appearance] setSubstituteFontName:fontName];
    
    [[self class] customizeNavigationBarWithBarColor:primaryColor textColor:ContrastColor(primaryColor, YES) fontName:fontName fontSize:20 buttonColor:ContrastColor(primaryColor, YES)];
    [[self class] customizeBarButtonItemWithPrimaryColor:primaryColor fontName:fontName fontSize:18 contentStyle:contentStyle];
    [[self class] customizeSegmentedControlWithPrimaryColor:primaryColor withFontName:fontName withFontSize:14 withContentStyle:contentStyle];
    [[self class] customizeButtonWithPrimaryColor:primaryColor secondaryColor:secondaryColor withContentStyle:contentStyle];
    [[self class] customizePageControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeProgressViewWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeSearchBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSliderWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeStepperWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSwitchWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeTabBarWithBarTintColor:FlatWhite andTintColor:primaryColor];
    [[self class] customizeToolbarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeImagePickerControllerWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    
    /*
     
     if (contentStyle == UIContentStyleContrast) {
     
     if ([ContrastColor(primaryColor, YES) isEqual:FlatWhite]) {
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
     } else {
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
     }
     
     } else if (contentStyle == UIContentStyleLight) {
     
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
     
     } else {
     
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
     }
     
     [[self class] customizeBarButtonItemWithPrimaryColor:primaryColor fontName:fontName fontSize:18 contentStyle:contentStyle];
     [[self class] customizeButtonWithPrimaryColor:primaryColor fontName:fontName fontSize:17 contentStyle:contentStyle];
     [[self class] customizeLabelWithPrimaryColor:primaryColor fontName:fontName fontSize:18 withContentStyle:contentStyle];
     [[self class] customizePageControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
     [[self class] customizeProgressViewWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
     [[self class] customizeSearchBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
     [[self class] customizeSliderWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
     [[self class] customizeStepperWithPrimaryColor:primaryColor withContentStyle:contentStyle];
     [[self class] customizeSwitchWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
     [[self class] customizeTabBarWithBarTintColor:FlatWhite tintColor:primaryColor fontName:fontName fontSize:11];
     [[self class] customizeToolbarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
     
     */
}

#pragma mark - UIBarButtonItem

+ (void)customizeBarButtonItemWithPrimaryColor:(UIColor *)primaryColor
                                  contentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UIBarButtonItem appearance] setTintColor:primaryColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:contentColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:contentColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setTintColor:contentColor];
    
    
}

+ (void)customizeBarButtonItemWithPrimaryColor:(UIColor *)primaryColor
                                      fontName:(NSString *)fontName
                                      fontSize:(float)fontSize
                                  contentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UIBarButtonItem appearance] setTintColor:primaryColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:contentColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:contentColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setTintColor:contentColor];
    
    
    if ([UIFont fontWithName:fontName size:fontSize]) {
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{ NSForegroundColorAttributeName:contentColor,
                                                                                                            NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} forState:UIControlStateNormal];
    }
}

#pragma mark - UIButton

+ (void)customizeButtonWithPrimaryColor:(UIColor *)primaryColor
                       withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UIButton appearance] setTintColor:contentColor];
    [[UIButton appearance] setBackgroundColor:primaryColor];
    
    [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedIn:[UIToolbar class], nil] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedIn:[UIToolbar class], nil] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedIn:[UIStepper class], nil] setTintColor:primaryColor];
    [[UIButton appearanceWhenContainedIn:[UIStepper class], nil] setBackgroundColor:ClearColor];
    
    [[UIButton appearance] setTitleShadowColor:ClearColor forState:UIControlStateNormal];
}

+ (void)customizeButtonWithPrimaryColor:(UIColor *)primaryColor
                         secondaryColor:(UIColor *)secondaryColor
                       withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    UIColor *secondaryContentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            secondaryContentColor = ContrastColor(secondaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            secondaryContentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            secondaryContentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            secondaryContentColor = ContrastColor(secondaryColor, NO);
            break;
        }
    }
    
    [[UIButton appearance] setTintColor:secondaryContentColor];
    [[UIButton appearance] setBackgroundColor:secondaryColor];
    
    [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedIn:[UIToolbar class], nil] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedIn:[UIToolbar class], nil] setBackgroundColor:ClearColor];
    
    [[UIButton appearanceWhenContainedIn:[UIStepper class], nil] setTintColor:primaryColor];
    [[UIButton appearanceWhenContainedIn:[UIStepper class], nil] setBackgroundColor:ClearColor];
    
    [[UIButton appearance] setTitleShadowColor:ClearColor forState:UIControlStateNormal];
}

#pragma mark - UIImagePickerController

+ (void)customizeImagePickerControllerWithPrimaryColor:(UIColor *)primaryColor withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    //Workaround for Swift http://stackoverflow.com/a/28765193
    [[UIButton appearanceWhenContainedWithin:@[[UIView class],[UIImagePickerController class]]] setBackgroundColor:ClearColor];
    [[UIButton appearanceWhenContainedWithin:@[[UIView class],[UIImagePickerController class]]] setTintColor:ClearColor];
    [[UIButton appearanceWhenContainedWithin:@[[UINavigationBar class],[UIImagePickerController class]]] setBackgroundColor:ClearColor];
    [[UIButton appearanceWhenContainedWithin:@[[UINavigationBar class],[UIImagePickerController class]]] setTintColor:contentColor];
    [[UIButton appearanceWhenContainedWithin:@[[UITableViewCell class],[UIImagePickerController class]]] setBackgroundColor:ClearColor];
    
    //[[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIView class],[UIImagePickerController class]]] setBackgroundColor:ClearColor];
    //[[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UIView class],[UIImagePickerController class]]] setTintColor:contentColor];
    //[[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class],[UIImagePickerController class]]] setBackgroundColor:ClearColor];
    //[[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class],[UIImagePickerController class]]] setTintColor:contentColor];
    //[[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UITableViewCell class],[UIImagePickerController class]]] setBackgroundColor:ClearColor];
}


#pragma mark - UILabel

+ (void)customizeLabelWithPrimaryColor:(UIColor *)primaryColor
                              fontName:(NSString *)fontName
                              fontSize:(CGFloat)fontSize
                      withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UILabel appearanceWhenContainedIn:[UINavigationBar class], nil] setTextColor:contentColor];
    [[UILabel appearanceWhenContainedIn:[UIToolbar class], nil] setTextColor:contentColor];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
    if (font) {
        [[UILabel appearance] setFont:[UIFont fontWithName:fontName size:fontSize]];
        [[UILabel appearanceWhenContainedIn:[UITextField class], nil] setFont:[UIFont fontWithName:fontName size:14]];
        [[UILabel appearanceWhenContainedIn:[UIButton class], nil] setFont:[UIFont fontWithName:fontName size:18]];
    }
}

#pragma mark - UINavigationBar

+ (void)customizeNavigationBarWithPrimaryColor:(UIColor *)primaryColor
                              withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UINavigationBar appearance] setBarTintColor:primaryColor];
    [[UINavigationBar appearance] setTintColor:contentColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:contentColor}];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    //    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

+ (void)customizeNavigationBarWithBarColor:(UIColor *)barColor
                                 textColor:(UIColor *)textColor
                               buttonColor:(UIColor *)buttonColor {
    
    [[UINavigationBar appearance] setBarTintColor:barColor];
    [[UINavigationBar appearance] setTintColor:buttonColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:textColor}];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    //    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

+ (void)customizeNavigationBarWithBarColor:(UIColor *)barColor
                                 textColor:(UIColor *)textColor
                                  fontName:(NSString *)fontName
                                  fontSize:(CGFloat)fontSize
                               buttonColor:(UIColor *)buttonColor {
    
    [[UINavigationBar appearance] setBarTintColor:barColor];
    [[UINavigationBar appearance] setTintColor:buttonColor];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    //    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    if ([UIFont fontWithName:fontName size:fontSize]) {
        [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize] }];
    }
}

#pragma mark - UIPageControl

+ (void)customizePageControlWithPrimaryColor:(UIColor *)primaryColor
                            withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:primaryColor];
    [[UIPageControl appearance] setPageIndicatorTintColor:[primaryColor colorWithAlphaComponent:0.4]];
    [[UIPageControl appearanceWhenContainedIn:[UINavigationBar class], nil] setCurrentPageIndicatorTintColor:contentColor];
    [[UIPageControl appearanceWhenContainedIn:[UINavigationBar class], nil] setPageIndicatorTintColor:[contentColor colorWithAlphaComponent:0.4]];
    [[UIPageControl appearanceWhenContainedIn:[UIToolbar class], nil] setCurrentPageIndicatorTintColor:contentColor];
    [[UIPageControl appearanceWhenContainedIn:[UIToolbar class], nil] setPageIndicatorTintColor:[contentColor colorWithAlphaComponent:0.4]];
}

#pragma mark - UIProgressView

+ (void)customizeProgressViewWithPrimaryColor:(UIColor *)primaryColor
                             withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UIProgressView appearance] setProgressTintColor:primaryColor];
    [[UIProgressView appearanceWhenContainedIn:[UINavigationBar class], nil] setProgressTintColor:contentColor];
    [[UIProgressView appearanceWhenContainedIn:[UIToolbar class], nil] setProgressTintColor:contentColor];
    [[UIProgressView appearance] setTrackTintColor:[UIColor lightGrayColor]];
    [[UIProgressView appearanceWhenContainedIn:[UINavigationBar class], nil] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UIProgressView appearanceWhenContainedIn:[UIToolbar class], nil] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

+ (void)customizeProgressViewWithPrimaryColor:(UIColor *)primaryColor
                            andSecondaryColor:(UIColor *)secondaryColor {
    
    [[UIProgressView appearance] setProgressTintColor:secondaryColor];
    [[UIProgressView appearanceWhenContainedIn:[UINavigationBar class], nil] setProgressTintColor:secondaryColor];
    [[UIProgressView appearanceWhenContainedIn:[UIToolbar class], nil] setProgressTintColor:secondaryColor];
    [[UIProgressView appearance] setTrackTintColor:[UIColor lightGrayColor]];
    [[UIProgressView appearanceWhenContainedIn:[UINavigationBar class], nil] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UIProgressView appearanceWhenContainedIn:[UIToolbar class], nil] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

#pragma mark - UISearchBar

+ (void)customizeSearchBarWithPrimaryColor:(UIColor *)primaryColor withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UISearchBar appearance] setBarTintColor:primaryColor];
    [[UISearchBar appearance] setBackgroundColor:primaryColor];
    [[UISearchBar appearance] setTintColor:contentColor];
    [[UISearchBar appearance] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

#pragma mark - UISegmentedControl

+ (void)customizeSegmentedControlWithPrimaryColor:(UIColor *)primaryColor
                                 withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UISegmentedControl appearance] setTintColor:primaryColor];
    [[UISegmentedControl appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTintColor:contentColor];
    [[UISegmentedControl appearanceWhenContainedIn:[UIToolbar class], nil]
     setTintColor:contentColor];
}

+ (void)customizeSegmentedControlWithPrimaryColor:(UIColor *)primaryColor
                                     withFontName:(NSString *)fontName
                                     withFontSize:(CGFloat)fontSize
                                 withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UISegmentedControl appearance] setTintColor:primaryColor];
    [[UISegmentedControl appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTintColor:contentColor];
    [[UISegmentedControl appearanceWhenContainedIn:[UIToolbar class], nil]
     setTintColor:contentColor];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if (font) {
        [[UISegmentedControl appearance] setTitleTextAttributes:@{NSFontAttributeName:font}
                                                       forState:UIControlStateNormal];
    }
}

#pragma mark - UISlider

+ (void)customizeSliderWithPrimaryColor:(UIColor *)primaryColor
                       withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UISlider appearance] setMinimumTrackTintColor:primaryColor];
    [[UISlider appearanceWhenContainedIn:[UINavigationBar class], nil] setMinimumTrackTintColor:contentColor];
    [[UISlider appearanceWhenContainedIn:[UIToolbar class], nil] setMinimumTrackTintColor:contentColor];
    [[UISlider appearance] setMaximumTrackTintColor:[UIColor lightGrayColor]];
    [[UISlider appearanceWhenContainedIn:[UINavigationBar class], nil] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UISlider appearanceWhenContainedIn:[UIToolbar class], nil] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    
    [[UISlider appearance] setThumbTintColor:primaryColor];
    [[UISlider appearanceWhenContainedIn:[UIToolbar class], nil] setThumbTintColor:contentColor];
}

+ (void)customizeSliderWithPrimaryColor:(UIColor *)primaryColor
                      andSecondaryColor:(UIColor *)secondaryColor {
    
    [[UISlider appearance] setMinimumTrackTintColor:secondaryColor];
    [[UISlider appearanceWhenContainedIn:[UINavigationBar class], nil] setMinimumTrackTintColor:secondaryColor];
    [[UISlider appearanceWhenContainedIn:[UIToolbar class], nil] setMinimumTrackTintColor:secondaryColor];
    [[UISlider appearance] setMaximumTrackTintColor:[UIColor lightGrayColor]];
    [[UISlider appearanceWhenContainedIn:[UINavigationBar class], nil] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UISlider appearanceWhenContainedIn:[UIToolbar class], nil] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    
    [[UISlider appearance] setThumbTintColor:secondaryColor];
    [[UISlider appearanceWhenContainedIn:[UIToolbar class], nil] setThumbTintColor:ContrastColor(primaryColor, NO)];
}

#pragma mark - UIStepper

+ (void)customizeStepperWithPrimaryColor:(UIColor *)primaryColor
                        withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UIStepper appearance] setTintColor:primaryColor];
    [[UIStepper appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTintColor:contentColor];
    [[UIStepper appearanceWhenContainedIn:[UIToolbar class], nil]
     setTintColor:contentColor];
}

#pragma mark - UISwitch

+ (void)customizeSwitchWithPrimaryColor:(UIColor *)primaryColor {
    
    [[UISwitch appearance] setOnTintColor:primaryColor];
    [[UISwitch appearanceWhenContainedIn:[UINavigationBar class], nil] setOnTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UISwitch appearanceWhenContainedIn:[UIToolbar class], nil] setOnTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

+ (void)customizeSwitchWithPrimaryColor:(UIColor *)primaryColor
                      andSecondaryColor:(UIColor *)secondaryColor {
    
    [[UISwitch appearance] setOnTintColor:secondaryColor];
    [[UISwitch appearanceWhenContainedIn:[UINavigationBar class], nil] setOnTintColor:secondaryColor];
    [[UISwitch appearanceWhenContainedIn:[UIToolbar class], nil] setOnTintColor:secondaryColor];
}

#pragma mark - UITabBar

+ (void)customizeTabBarWithBarTintColor:(UIColor *)barTintColor
                           andTintColor:(UIColor *)tintColor {
    
    [[UITabBar appearance] setBarTintColor:barTintColor];
    [[UITabBar appearance] setTintColor:tintColor];
}

+ (void)customizeTabBarWithBarTintColor:(UIColor *)barTintColor
                              tintColor:(UIColor *)tintColor
                               fontName:(NSString *)fontName
                               fontSize:(CGFloat)fontSize {
    
    [[UITabBar appearance] setBarTintColor:barTintColor];
    [[UITabBar appearance] setTintColor:tintColor];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if (font) {
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:font}
                                                 forState:UIControlStateNormal];
    }
}

#pragma mark - UIToolbar

+ (void)customizeToolbarWithPrimaryColor:(UIColor *)primaryColor
                        withContentStyle:(UIContentStyle)contentStyle {
    
    UIColor *contentColor;
    switch (contentStyle) {
        case UIContentStyleContrast: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
        case UIContentStyleLight: {
            contentColor = [UIColor whiteColor];
            break;
        }
        case UIContentStyleDark: {
            contentColor = FlatBlackDark;
            break;
        }
        default: {
            contentColor = ContrastColor(primaryColor, NO);
            break;
        }
    }
    
    [[UIToolbar appearance] setTintColor:contentColor];
    [[UIToolbar appearance] setBarTintColor:primaryColor];
    [[UIToolbar appearance] setClipsToBounds:YES];
}

#pragma GCC diagnostic pop

@end
