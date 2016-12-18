//
//  ZCAnimatedLabel.h
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 2/13/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZCEasingUtil.h"
#import "ZCCoreTextLayout.h"


typedef NS_ENUM(NSInteger, ZCAnimatedLabelAppearDirection)
{
    ZCAnimatedLabelAppearDirectionFromBottom,
    ZCAnimatedLabelAppearDirectionFromCenter,
    ZCAnimatedLabelAppearDirectionFromTop,
    ZCAnimatedLabelAppearDirectionFromTopLeft,
};


@interface ZCAnimatedLabel : UIView

/**
 * time for one text attribute to do completion animation
 */
@property (nonatomic, assign) CGFloat animationDuration;

/**
 * start time offset for each group
 */
@property (nonatomic, assign) CGFloat animationDelay;

/**
 * duration for the label to finish animation on screen
 */
@property (nonatomic, readonly) CGFloat totoalAnimationDuration;

/**
 * font, text, textColor, attributedString
 * similar to how it works in UILabel
 */
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, strong) NSAttributedString *attributedString;

/**
 * If YES, eash text block will be CALayer instead of redraw
 * default to NO
 */
@property (nonatomic, assign) BOOL layerBased;

/**
 * If set to YES, will use a new random background color for each redraw
 */
@property (nonatomic, assign) BOOL debugRedraw;

/**
 * If set to YES, will show bounds of each TextBlock
 */
@property (nonatomic, assign) BOOL debugTextBlockBounds;

/**
 * If set to NO, whole rect will be redrawn on each displayLink tick
 * default to YES
 */
@property (nonatomic, assign) BOOL onlyDrawDirtyArea;

/**
 * Appear direction only works in default implemention
 * add your own option in subclass implemention
 */
@property (nonatomic, assign) ZCAnimatedLabelAppearDirection appearDirection;
@property (nonatomic, readonly) ZCCoreTextLayout *layoutTool;

/**
 * animatingAppear = NO means it's in animate disappear mode
 */
@property (nonatomic, readonly) BOOL animatingAppear;


/**
 * preferedMaxLayoutWidth
 */

@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;


- (void) sizeToFit;

- (void) startAppearAnimation;

- (void) startDisappearAnimation;

- (void) stopAnimation;

/**
 * One time init after the layout is done, use customValue to retain custom attributes
 */
- (void) textBlockAttributesInit: (ZCTextBlock *) textBlock;


/**
 * Custom drawing methods for appear animation
 * Only used when layerBased is set to NO
 *
 * @param rect The area of redraw
 * @param textBlock The text block object needed to do custom drawing
 */
- (void) appearStateDrawingForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock;

- (void) disappearStateDrawingForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock;

/**
 * Override this to decide which part of the rect needs redraw,
 * Only used when layerBased is set to NO
 * @return custom area that should be redrawn
 */
- (CGRect) redrawAreaForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock;


/**
 * Custom changes to the layer of each TextBlock
 * Only used when layerBased is set to YES
 */
- (void) appearStateLayerChangesForTextBlock: (ZCTextBlock *) textBlock;

- (void) disappearLayerStateChangesForTextBlock: (ZCTextBlock *) textBlock;





@end
