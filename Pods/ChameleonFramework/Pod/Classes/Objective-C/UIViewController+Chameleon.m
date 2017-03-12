//
//  UIViewController+Chameleon.m
//  Chameleon
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import "UIViewController+Chameleon.h"
#import <objc/runtime.h>

#import "ChameleonConstants.h"
#import "ChameleonEnums.h"
#import "ChameleonMacros.h"

#import "NSArray+Chameleon.h"
#import "UIColor+Chameleon.h"
#import "UIViewController+Chameleon.h"
#import "UIView+ChameleonPrivate.h"
#import "UILabel+Chameleon.h"
#import "UIButton+Chameleon.h"
#import "UIAppearance+Swift.h"

@interface UIViewController ()

@property (readwrite) BOOL shouldContrast;
@property (readwrite) BOOL shouldUseLightContent;

@end

@implementation UIViewController (Chameleon)


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - Runtime

- (void)setShouldContrast:(BOOL)contrast {
    
    NSNumber *number = [NSNumber numberWithBool:contrast];
    objc_setAssociatedObject(self, @selector(shouldContrast), number, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)shouldContrast {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(shouldContrast));
    return [number boolValue];
}

- (void)setShouldUseLightContent:(BOOL)shouldUseLightContent {
    
    NSNumber *number = [NSNumber numberWithBool:shouldUseLightContent];
    objc_setAssociatedObject(self, @selector(shouldUseLightContent), number, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)shouldUseLightContent {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(shouldUseLightContent));
    return [number boolValue];
}

#pragma mark - Swizzling

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL originalSelector = @selector(preferredStatusBarStyle);
        SEL swizzledSelector = @selector(chameleon_preferredStatusBarStyle);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
            
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Methods


- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    
    if (statusBarStyle == UIStatusBarStyleContrast) {
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate) withObject:nil afterDelay:0.01];
        self.shouldContrast = YES;
        
    } else {
        
        if (statusBarStyle == UIStatusBarStyleLightContent) {
            
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate) withObject:nil afterDelay:0.01];
            self.shouldUseLightContent = YES;
            
        } else {
            
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate) withObject:nil afterDelay:0.01];
            self.shouldUseLightContent = NO;
        }
    }
    
    [self preferredStatusBarStyle];
}

- (UIStatusBarStyle)chameleon_preferredStatusBarStyle {
    
    [self chameleon_preferredStatusBarStyle];
    
    if (self.shouldContrast) {

        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        UIView *topView = [self.view findTopMostViewForPoint:CGPointMake(CGRectGetMidX(statusBarFrame), 2)];
        
        return [self contrastingStatusBarStyleForColor:topView.backgroundColor];
        
    } else {
        
        if (self.shouldUseLightContent) {
            return UIStatusBarStyleLightContent;
            
        } else {
            return [self chameleon_preferredStatusBarStyle];
        }
    }
}

- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
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

- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
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

- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
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
    
    [[self class] customizeButtonWithPrimaryColor:primaryColor secondaryColor:secondaryColor withContentStyle:contentStyle];
    [[self class] customizeBarButtonItemWithPrimaryColor:primaryColor fontName:fontName fontSize:18 contentStyle:contentStyle];
    [[self class] customizeNavigationBarWithBarColor:primaryColor textColor:ContrastColor(primaryColor, YES) fontName:fontName fontSize:20 buttonColor:ContrastColor(primaryColor, YES)];
    [[self class] customizePageControlWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeProgressViewWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeSearchBarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSegmentedControlWithPrimaryColor:primaryColor withFontName:fontName withFontSize:14 withContentStyle:contentStyle];
    [[self class] customizeSliderWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeStepperWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeSwitchWithPrimaryColor:primaryColor andSecondaryColor:secondaryColor];
    [[self class] customizeTabBarWithBarTintColor:FlatWhite andTintColor:primaryColor];
    [[self class] customizeToolbarWithPrimaryColor:primaryColor withContentStyle:contentStyle];
    [[self class] customizeImagePickerControllerWithPrimaryColor:primaryColor withContentStyle:contentStyle];
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
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:contentColor, NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} forState:UIControlStateNormal];
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
    
    [[UILabel appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setTextColor:contentColor];
    [[UILabel appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setTextColor:contentColor];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
    if (font) {
        [[UILabel appearanceWhenContainedIn:[self class], nil] setFont:[UIFont fontWithName:fontName size:fontSize]];
        [[UILabel appearanceWhenContainedIn:[self class], [UITextField class], nil] setFont:[UIFont fontWithName:fontName size:14]];
        [[UILabel appearanceWhenContainedIn:[self class], [UIButton class], nil] setFont:[UIFont fontWithName:fontName size:18]];
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
    
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setBarTintColor:primaryColor];
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTintColor:contentColor];
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:contentColor}];
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setShadowImage:[UIImage new]];
//    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

+ (void)customizeNavigationBarWithBarColor:(UIColor *)barColor
                                 textColor:(UIColor *)textColor
                               buttonColor:(UIColor *)buttonColor {
    
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setBarTintColor:barColor];
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTintColor:buttonColor];
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:textColor}];
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setShadowImage:[UIImage new]];
//    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

+ (void)customizeNavigationBarWithBarColor:(UIColor *)barColor
                                 textColor:(UIColor *)textColor
                                  fontName:(NSString *)fontName
                                  fontSize:(CGFloat)fontSize
                               buttonColor:(UIColor *)buttonColor {
    
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setBarTintColor:barColor];
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTintColor:buttonColor];
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setShadowImage:[UIImage new]];
//    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    if ([UIFont fontWithName:fontName size:fontSize]) {
        [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTitleTextAttributes:@{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize] }];
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
    
    [[UIPageControl appearanceWhenContainedIn:[self class], nil] setCurrentPageIndicatorTintColor:primaryColor];
    [[UIPageControl appearanceWhenContainedIn:[self class], nil] setPageIndicatorTintColor:[primaryColor colorWithAlphaComponent:0.4]];
    [[UIPageControl appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setCurrentPageIndicatorTintColor:contentColor];
    [[UIPageControl appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setPageIndicatorTintColor:[contentColor colorWithAlphaComponent:0.4]];
    [[UIPageControl appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setCurrentPageIndicatorTintColor:contentColor];
    [[UIPageControl appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setPageIndicatorTintColor:[contentColor colorWithAlphaComponent:0.4]];
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
    
    [[UIProgressView appearanceWhenContainedIn:[self class], nil] setProgressTintColor:primaryColor];
    [[UIProgressView appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setProgressTintColor:contentColor];
    [[UIProgressView appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setProgressTintColor:contentColor];
    [[UIProgressView appearanceWhenContainedIn:[self class], nil] setTrackTintColor:[UIColor lightGrayColor]];
    [[UIProgressView appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UIProgressView appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

+ (void)customizeProgressViewWithPrimaryColor:(UIColor *)primaryColor
                            andSecondaryColor:(UIColor *)secondaryColor {
    
    [[UIProgressView appearanceWhenContainedIn:[self class], nil] setProgressTintColor:secondaryColor];
    [[UIProgressView appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setProgressTintColor:secondaryColor];
    [[UIProgressView appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setProgressTintColor:secondaryColor];
    [[UIProgressView appearanceWhenContainedIn:[self class], nil] setTrackTintColor:[UIColor lightGrayColor]];
    [[UIProgressView appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UIProgressView appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
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
    
    [[UISearchBar appearanceWhenContainedIn:[self class], nil] setBarTintColor:primaryColor];
    [[UISearchBar appearanceWhenContainedIn:[self class], nil] setBackgroundColor:primaryColor];
    [[UISearchBar appearanceWhenContainedIn:[self class], nil] setTintColor:contentColor];
    [[UISearchBar appearanceWhenContainedIn:[self class], nil] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
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
    
    [[UISegmentedControl appearanceWhenContainedIn:[self class], nil] setTintColor:primaryColor];
    [[UISegmentedControl appearanceWhenContainedIn:[self class], [UINavigationBar class], nil]
     setTintColor:contentColor];
    [[UISegmentedControl appearanceWhenContainedIn:[self class], [UIToolbar class], nil]
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
    
    [[UISegmentedControl appearanceWhenContainedIn:[self class], nil] setTintColor:primaryColor];
    [[UISegmentedControl appearanceWhenContainedIn:[self class], [UINavigationBar class], nil]
     setTintColor:contentColor];
    [[UISegmentedControl appearanceWhenContainedIn:[self class], [UIToolbar class], nil]
     setTintColor:contentColor];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if (font) {
        [[UISegmentedControl appearanceWhenContainedIn:[self class], nil] setTitleTextAttributes:@{NSFontAttributeName:font}
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
    
    [[UISlider appearanceWhenContainedIn:[self class], nil] setMinimumTrackTintColor:primaryColor];
    [[UISlider appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setMinimumTrackTintColor:contentColor];
    [[UISlider appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setMinimumTrackTintColor:contentColor];
    [[UISlider appearanceWhenContainedIn:[self class], nil] setMaximumTrackTintColor:[UIColor lightGrayColor]];
    [[UISlider appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UISlider appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

+ (void)customizeSliderWithPrimaryColor:(UIColor *)primaryColor
                      andSecondaryColor:(UIColor *)secondaryColor {
    
    [[UISlider appearanceWhenContainedIn:[self class], nil] setMinimumTrackTintColor:secondaryColor];
    [[UISlider appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setMinimumTrackTintColor:secondaryColor];
    [[UISlider appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setMinimumTrackTintColor:secondaryColor];
    [[UISlider appearanceWhenContainedIn:[self class], nil] setMaximumTrackTintColor:[UIColor lightGrayColor]];
    [[UISlider appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UISlider appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setMaximumTrackTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
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
    
    [[UIStepper appearanceWhenContainedIn:[self class], nil] setTintColor:primaryColor];
    [[UIStepper appearanceWhenContainedIn:[self class], [UINavigationBar class], nil]
     setTintColor:contentColor];
    [[UIStepper appearanceWhenContainedIn:[self class], [UIToolbar class], nil]
     setTintColor:contentColor];
}

#pragma mark - UISwitch

+ (void)customizeSwitchWithPrimaryColor:(UIColor *)primaryColor {
    
    [[UISwitch appearanceWhenContainedIn:[self class], nil] setOnTintColor:primaryColor];
    [[UISwitch appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setOnTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
    [[UISwitch appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setOnTintColor:[[primaryColor darkenByPercentage:0.25] flatten]];
}

+ (void)customizeSwitchWithPrimaryColor:(UIColor *)primaryColor
                      andSecondaryColor:(UIColor *)secondaryColor {
    
    [[UISwitch appearanceWhenContainedIn:[self class], nil] setOnTintColor:secondaryColor];
    [[UISwitch appearanceWhenContainedIn:[self class], [UINavigationBar class], nil] setOnTintColor:secondaryColor];
    [[UISwitch appearanceWhenContainedIn:[self class], [UIToolbar class], nil] setOnTintColor:secondaryColor];
}

#pragma mark - UITabBar

+ (void)customizeTabBarWithBarTintColor:(UIColor *)barTintColor
                           andTintColor:(UIColor *)tintColor {
    
    [[UITabBar appearanceWhenContainedIn:[self class], nil] setBarTintColor:barTintColor];
    [[UITabBar appearanceWhenContainedIn:[self class], nil] setTintColor:tintColor];
}

+ (void)customizeTabBarWithBarTintColor:(UIColor *)barTintColor
                              tintColor:(UIColor *)tintColor
                               fontName:(NSString *)fontName
                               fontSize:(CGFloat)fontSize {
    
    [[UITabBar appearanceWhenContainedIn:[self class], nil] setBarTintColor:barTintColor];
    [[UITabBar appearanceWhenContainedIn:[self class], nil] setTintColor:tintColor];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if (font) {
        [[UITabBarItem appearanceWhenContainedIn:[self class], nil] setTitleTextAttributes:@{NSFontAttributeName:font}
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
    
    [[UIToolbar appearanceWhenContainedIn:[self class], nil] setTintColor:contentColor];
    [[UIToolbar appearanceWhenContainedIn:[self class], nil] setBarTintColor:primaryColor];
    [[UIToolbar appearanceWhenContainedIn:[self class], nil] setClipsToBounds:YES];
}


#pragma mark - Private Methods

- (UIStatusBarStyle)contrastingStatusBarStyleForColor:(UIColor *)backgroundColor {
    
    //Calculate Luminance
    CGFloat luminance;
    CGFloat red, green, blue;
    
    //Check for clear or uncalculatable color and assume white
    if (![backgroundColor getRed:&red green:&green blue:&blue alpha:nil]) {
        return UIStatusBarStyleDefault;
    }
    
    //Relative luminance in colorimetric spaces - http://en.wikipedia.org/wiki/Luminance_(relative)
    red *= 0.2126f; green *= 0.7152f; blue *= 0.0722f;
    luminance = red + green + blue;
    
    return (luminance > 0.6f) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

#pragma GCC diagnostic pop

@end
