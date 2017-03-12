//
//  UIButton+Chameleon.m
//  Chameleon
//
//  Created by Vicc Alexander on 9/20/15.
//  Copyright © 2015 Vicc Alexander. All rights reserved.
//

#import "UIButton+Chameleon.h"

@implementation UIButton (Chameleon)

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)setSubstituteFontName:(NSString *)name UI_APPEARANCE_SELECTOR {
    
    self.font = [UIFont fontWithName:name size:self.font.pointSize];
}

#pragma GCC diagnostic pop

@end
