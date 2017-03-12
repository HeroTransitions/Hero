//
//  UINavigationController+Chameleon.m
//  ChameleonDemo
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import "UINavigationController+Chameleon.h"
#import <objc/runtime.h>

#import "ChameleonConstants.h"
#import "ChameleonEnums.h"
#import "ChameleonMacros.h"

#import "NSArray+Chameleon.h"
#import "UIColor+Chameleon.h"
#import "UIViewController+Chameleon.h"

@interface UINavigationController ()

@property (readwrite) BOOL shouldContrast;
@property (readwrite) BOOL shouldUseLightContent;

@end

@implementation UINavigationController (Chameleon)

@dynamic hidesNavigationBarHairline;

#pragma mark - Swizzling

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL originalSelector = @selector(viewDidLoad);
        SEL swizzledSelector = @selector(chameleon_viewDidLoad);
        
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

- (void)chameleon_viewDidLoad {
   
    [self chameleon_viewDidLoad];
    
    UIView *hairlineImageView = [self findHairlineImageViewUnder:self.navigationBar];
    
    if (hairlineImageView) {
        
        if (self.hidesNavigationBarHairline) {
             hairlineImageView.hidden = YES;
            
        } else {
             hairlineImageView.hidden = NO;
        }
    }
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    
    return nil;
}

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

- (void)setHidesNavigationBarHairline:(BOOL)hidesNavigationBarHairline {
    
    NSNumber *number = [NSNumber numberWithBool:hidesNavigationBarHairline];
    objc_setAssociatedObject(self, @selector(hidesNavigationBarHairline), number, OBJC_ASSOCIATION_RETAIN);
    
    //Find Hairline Image
    UIView *hairlineImageView = [self findHairlineImageViewUnder:self.navigationBar];
    
    //Check if it exists
    if (hairlineImageView) {
        
        //Check if we should hide it or not
        if (hidesNavigationBarHairline) {
            hairlineImageView.hidden = YES;
            
        } else {
            hairlineImageView.hidden = NO;
        }
    }
}

- (BOOL)hidesNavigationBarHairline {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(hidesNavigationBarHairline));
    return [number boolValue];
}


#pragma mark - Public Methods

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    
    if (statusBarStyle == UIStatusBarStyleContrast) {
        
        self.shouldContrast = YES;
        
    } else {
       
        if (statusBarStyle == UIStatusBarStyleLightContent) {
            
            self.shouldUseLightContent = YES;
            
        } else {
            
            self.shouldUseLightContent = NO;
        }
        
    }
}

#pragma mark - Private Methods

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    [super preferredStatusBarStyle];
    
    if (self.shouldContrast) {
        
        return [self contrastingStatusBarStyleForColor:self.navigationBar.barTintColor];
        
    } else {
        
        if (self.shouldUseLightContent) {
            
            return UIStatusBarStyleLightContent;
            
        } else {
            
            return UIStatusBarStyleDefault;
        }
    }
}

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

@end
