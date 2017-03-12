//
//  UIColor+ChameleonPrivate.h
//  Chameleon
//
//  Created by Vicc Alexander on 6/6/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIColor (ChameleonPrivate)

@property (nonatomic, readwrite) NSUInteger count;

#pragma mark - Class Methods

+ (UIColor *)colorFromImage:(UIImage *)image atPoint:(CGPoint)point;

- (UIColor *)colorWithMinimumSaturation:(CGFloat)saturation;

#pragma mark - Instance Methods

- (BOOL)isDistinct:(UIColor *)color;

- (BOOL)getValueForX:(CGFloat *)X
           valueForY:(CGFloat *)Y
           valueForZ:(CGFloat *)Z
               alpha:(CGFloat *)alpha;

- (BOOL)getLightness:(CGFloat *)L
           valueForA:(CGFloat *)A
           valueForB:(CGFloat *)B
               alpha:(CGFloat *)alpha;

@end
