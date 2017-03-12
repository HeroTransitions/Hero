//
//  ChameleonEnums.h
//  Chameleon
//
//  Created by Vicc Alexander on 6/8/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#ifndef Chameleon_ChameleonEnums_h
#define Chameleon_ChameleonEnums_h

/**
 *  Specifies how text-based UI elements and other content such as switch knobs, should be colored.
 *
 *  @since 2.0
 */

typedef NS_ENUM(NSUInteger, UIContentStyle) {
    /**
     *  Automatically chooses and colors text-based elements with the shade that best contrasts its @c backgroundColor.
     *
     *  @since 2.0
     */
    UIContentStyleContrast,
    /**
     *  Colors text-based elements using a light shade.
     *
     *  @since 2.0
     */
    UIContentStyleLight,
    /**
     *  Colors text-based elements using a light shade.
     *
     *  @since 2.0
     */
    UIContentStyleDark
};

#endif
