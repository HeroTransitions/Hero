//
//  ZCCoreTextLayout.h
//  ZCAnimatedLabel
//
//  Core Text based layout
//
//
//  Created by Chen Zhang on 3/2/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZCLayoutGroupType)
{
    ZCLayoutGroupChar,
    ZCLayoutGroupWord,
    ZCLayoutGroupLine,
};


@interface ZCTextBlockLayer : CALayer

@property (nonatomic, strong) NSAttributedString *attributedString;

@end


@interface ZCTextBlock : NSObject

@property (nonatomic, assign) CGRect charRect;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSRange textRange;

/** 
 * if wanted to override default value from attributedString
 s*/
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

/**
 * attributes derived from current draw state, used to draw
 */
@property (nonatomic, readonly) UIColor *derivedTextColor;
@property (nonatomic, readonly) UIFont *derivedFont;
@property (nonatomic, readonly) NSAttributedString *derivedAttributedString;

@property (nonatomic, assign) BOOL ended; //flag, won't redraw if set to YES
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat startDelay;
@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, strong) ZCTextBlockLayer *textBlockLayer;

/**
 * place holder for customValue
 */
@property (nonatomic, strong) id customValue;

- (void) updateBaseAttributedString: (NSAttributedString *) attributedString;

@end



@interface ZCCoreTextLayout : NSObject

- (void) cleanLayout;
- (void) layoutWithAttributedString: (NSAttributedString *) attributedString constainedToSize: (CGSize) size;
- (CGFloat) estimatedHeight;


@property (nonatomic, assign) BOOL layerBased;
@property (nonatomic, strong) NSArray *textBlocks;
@property (nonatomic, assign) ZCLayoutGroupType groupType;


@end
