//
//  UILabel+Chameleon.m
//  Chameleon
//
//  Created by Vicc Alexander on 9/20/15.
//  Copyright © 2015 Vicc Alexander. All rights reserved.
//

#import "UILabel+Chameleon.h"

@implementation UILabel (Chameleon)

- (void)setSubstituteFontName:(NSString *)name UI_APPEARANCE_SELECTOR {
    
    self.font = [UIFont fontWithName:name size:self.font.pointSize];
}

@end
