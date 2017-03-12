//
//  ZCCoreTextLayout.m
//  ZCAnimatedLabel
//
//  CoreText based layout to separate each ZCTextAttributes
//
//  Created by Chen Zhang on 3/2/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//
//
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import "ZCCoreTextLayout.h"


@implementation ZCTextBlockLayer

- (instancetype) init
{
    if (self = [super init]) {
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void) drawInContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    [self.attributedString drawInRect:self.bounds];
    UIGraphicsPopContext();
}
@end



@interface ZCTextBlock ()

@property (nonatomic, readwrite) NSAttributedString *derivedAttributedString;

@end

@implementation ZCTextBlock

- (NSString *) description
{
    return [NSString stringWithFormat:@"[%@ %@, %@, %f]", [self class], self.text, NSStringFromCGRect(self.charRect), self.progress];
}

- (void) updateBaseAttributedString: (NSAttributedString *) attributedString
{
    _derivedAttributedString = attributedString;
}

- (NSAttributedString *) derivedAttributedString
{
    if (!self.font && !self.textColor) {
        return _derivedAttributedString; //nothing changed
    }
    NSMutableAttributedString *mutableCopy = [_derivedAttributedString mutableCopy];
    NSRange fullRange = NSMakeRange(0, _derivedAttributedString.string.length);
    if(self.font) [mutableCopy addAttribute:NSFontAttributeName value:self.font range:fullRange];
    if(self.textColor) [mutableCopy addAttribute:NSForegroundColorAttributeName value:self.textColor range:fullRange];
    
    return mutableCopy;
}

- (UIColor *) derivedTextColor
{
    return [_derivedAttributedString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
}

- (UIFont *) derivedFont
{
    return [_derivedAttributedString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
}

@end

@interface ZCCoreTextLayout ()

@property (nonatomic, assign) CGSize estimatedSize;

@end


@implementation ZCCoreTextLayout

- (instancetype) init
{
    if (self = [super init]) {
        self.groupType = ZCLayoutGroupChar;
    }
    return self;
}

- (void) cleanLayout
{
    self.textBlocks = nil;
}


- (void) layoutWithAttributedString: (NSAttributedString *) attributedString constainedToSize: (CGSize) size {
    NSString *text = [attributedString string];
    if ([text length] < 1) {
        return;
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef ctFrame;
    CGRect frameRect;
    CFRange rangeAll = CFRangeMake(0, text.length);

    
    // Measure how mush specec will be needed for this attributed string
    // So we can find minimun frame needed
    CFRange fitRange;
    CGSize s = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeAll, NULL, CGSizeMake(size.width, MAXFLOAT), &fitRange);
    
    self.estimatedSize = s;
    
    frameRect = CGRectMake(0, 0, s.width, s.height);
    CGPathRef framePath = CGPathCreateWithRect(frameRect, NULL);
    ctFrame = CTFramesetterCreateFrame(framesetter, rangeAll, framePath, NULL);
    CGPathRelease(framePath);
    
    // Get the lines in our frame
    NSArray* lines = (NSArray*)CTFrameGetLines(ctFrame);
    NSUInteger lineCount = [lines count];
    
    CGPoint *lineOrigins = malloc(sizeof(CGPoint) * lineCount);
    CGRect *lineFrames = malloc(sizeof(CGRect) * lineCount);
    
    // Get the origin point of each of the lines
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    // Solution borrowew from (but simplified):
    // https://github.com/twitter/twui/blob/master/lib/Support/CoreText%2BAdditions.m
    
    //layout done add into textAttributes
    NSMutableArray *textAttributes = [NSMutableArray arrayWithCapacity:3];

    CGFloat startOffsetY = 0;

    // Loop throught the lines
    for(CFIndex i = 0; i < lineCount; ++i) {
        
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        
        CFRange lineRange = CTLineGetStringRange(line);

        CGPoint lineOrigin = lineOrigins[i];
        CGFloat ascent, descent, leading;
        CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        // If we have more than 1 line, we want to find the real height of the line by measuring the distance between the current line and previous line. If it's only 1 line, then we'll guess the line's height.
        BOOL useRealHeight = i < lineCount - 1;
        CGFloat neighborLineY = i > 0 ? lineOrigins[i - 1].y : (lineCount - 1 > i ? lineOrigins[i + 1].y : 0.0f);
        CGFloat lineHeight = ceil(useRealHeight ? fabs(neighborLineY - lineOrigin.y) : ascent + descent + leading);
        
        lineFrames[i].origin = lineOrigin;
        lineFrames[i].size = CGSizeMake(lineWidth, lineHeight);
        
        NSString *lineString = [text substringWithRange:NSMakeRange(lineRange.location, lineRange.length)];

        NSStringEnumerationOptions options = 0;
        switch (self.groupType) {
            case ZCLayoutGroupChar:
                options = NSStringEnumerationByComposedCharacterSequences;
                break;
            case ZCLayoutGroupWord:
                options = NSStringEnumerationByWords;
                break;
            case ZCLayoutGroupLine:
                options = NSStringEnumerationBySentences;
                break;
            default:
                break;
        }
        
        //first pass
        __block CGFloat maxDescender = 0;
        __block CGFloat maxCharHeight = 0;
        [lineString enumerateSubstringsInRange:NSMakeRange(0, lineRange.length) options:options usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            NSMutableAttributedString *subLineString = [[attributedString attributedSubstringFromRange:NSMakeRange(enclosingRange.location + lineRange.location, enclosingRange.length)] mutableCopy];
            UIFont *font = [subLineString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
            maxDescender = MAX(maxDescender, font.descender > 0 ? font.descender : -font.descender);
            maxCharHeight = MAX(maxCharHeight, font.xHeight + font.ascender + font.descender);
        }];
         
        [lineString enumerateSubstringsInRange:NSMakeRange(0, lineRange.length) options:options usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            ZCTextBlock *textBlock = [[ZCTextBlock alloc] init];
            textBlock.text = [lineString substringWithRange:enclosingRange];
            textBlock.textRange = enclosingRange;
            NSMutableAttributedString *subLineString = [[attributedString attributedSubstringFromRange:NSMakeRange(enclosingRange.location + lineRange.location, enclosingRange.length)] mutableCopy];
            [subLineString removeAttribute:NSParagraphStyleAttributeName range:NSMakeRange(0, subLineString.length)];
            UIFont *font = [subLineString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
            [textBlock updateBaseAttributedString:subLineString];
            
            CGFloat startOffset = CTLineGetOffsetForStringIndex(line, enclosingRange.location + lineRange.location, NULL);
            CGFloat endOffset = CTLineGetOffsetForStringIndex(line, enclosingRange.location + enclosingRange.length + lineRange.location, NULL);
            
            CGFloat realHeight = font.xHeight + font.ascender + font.descender;
            CGFloat absAscender = font.descender > 0 ? font.descender : -font.descender;
            CGFloat originDiff = (maxCharHeight - realHeight) - (maxDescender - absAscender);

            if (self.groupType == ZCLayoutGroupLine) {
                realHeight = lineHeight;
                originDiff = 0;
            }
            textBlock.charRect = CGRectMake(startOffset + lineOrigins[i].x, startOffsetY + originDiff, endOffset - startOffset, realHeight);
            [textAttributes addObject:textBlock];
            
            if (self.layerBased) {                
                ZCTextBlockLayer *textBlockLayer = [[ZCTextBlockLayer alloc] init];
                textBlockLayer.frame = textBlock.charRect;
                textBlockLayer.attributedString = subLineString;
                textBlockLayer.backgroundColor = [UIColor clearColor].CGColor;
                textBlock.textBlockLayer = textBlockLayer;
            }
        }];
        
        startOffsetY += lineHeight;
        
    }
    
    self.textBlocks = textAttributes;
    
    //free stuff
    free(lineOrigins);
    free(lineFrames);
}



- (CGFloat) estimatedHeight
{
    return self.estimatedSize.height;
}


@end
