//
//  UIAppearance+Swift.m
//  Chameleon
//
//  Created by Vicc Alexander on 11/26/15.
//  Copyright © 2015 Vicc Alexander. All rights reserved.
//

#import "UIAppearance+Swift.h"

@implementation UIView (UIViewAppearance_Swift)

+ (instancetype)appearanceWhenContainedWithin: (NSArray *)containers {
    
    NSUInteger count = containers.count;
    NSAssert(count <= 10, @"The count of containers greater than 10 is not supported.");
    
    return [self appearanceWhenContainedIn:
            count > 0 ? containers[0] : nil,
            count > 1 ? containers[1] : nil,
            count > 2 ? containers[2] : nil,
            count > 3 ? containers[3] : nil,
            count > 4 ? containers[4] : nil,
            count > 5 ? containers[5] : nil,
            count > 6 ? containers[6] : nil,
            count > 7 ? containers[7] : nil,
            count > 8 ? containers[8] : nil,
            count > 9 ? containers[9] : nil,
            nil];
}

@end
