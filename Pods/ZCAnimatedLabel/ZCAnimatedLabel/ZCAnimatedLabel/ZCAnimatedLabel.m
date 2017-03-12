//
//  ZCAnimatedLabel.m
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 2/13/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import "ZCAnimatedLabel.h"
#import "ZCEasingUtil.h"


@interface ZCAnimatedLabel ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval animationTime;
@property (nonatomic, assign) BOOL useDefaultDrawing;
@property (nonatomic, assign) NSTimeInterval animationDurationTotal;
@property (nonatomic, assign) BOOL animatingAppear; //we are during appear stage or not
@property (nonatomic, strong) ZCCoreTextLayout *layoutTool;
@property (nonatomic, assign) NSTimeInterval animationStarTime;

@end

@implementation ZCAnimatedLabel

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype) init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit
{
    self.backgroundColor = [UIColor clearColor];

    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerTick:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink.paused = YES;
    
    _animationDuration = 1;
    _animationDelay = 0.1;
    _appearDirection = ZCAnimatedLabelAppearDirectionFromBottom;
    _layoutTool = [[ZCCoreTextLayout alloc] init];
    _onlyDrawDirtyArea = YES;
    
    _useDefaultDrawing = YES;
    _text = @"";
    _font = [UIFont systemFontOfSize:15];
    
    _debugTextBlockBounds = NO;
    _layerBased = NO;
}


- (CGFloat) totoalAnimationDuration
{
    return self.animationDurationTotal;
}

- (void) timerTick: (id) sender
{
    if (self.animationStarTime <= 0) {
        self.animationStarTime = self.displayLink.timestamp;
    }
    self.animationTime = self.displayLink.timestamp - self.animationStarTime;
    if (self.animationTime > self.animationDurationTotal) {
        self.displayLink.paused = YES;
        self.useDefaultDrawing = YES;
    }
    else { //update text attributeds array
        
        [self.layoutTool.textBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ZCTextBlock *textBlock = self.layoutTool.textBlocks[idx];
            NSUInteger sequence = self.animatingAppear ? idx : (self.layoutTool.textBlocks.count - idx - 1);
            //udpate attribute according to progress
            CGFloat progress = 0;
            CGFloat startDelay = textBlock.startDelay > 0 ? textBlock.startDelay : sequence * self.animationDelay;
            NSTimeInterval timePassed = self.animationTime - startDelay;
            CGFloat duration = textBlock.duration > 0 ? textBlock.duration : self.animationDuration;
            if (timePassed > duration && !textBlock.ended) {
                progress = 1;
                textBlock.ended = YES; //ended
                textBlock.progress = progress;
                if (self.layerBased) {
                    [self updateViewStateWithTextBlock:textBlock];
                }
                else {
                    CGRect dityRect = [self redrawAreaForRect:self.bounds textBlock:textBlock];
                    [self setNeedsDisplayInRect:dityRect];
                }
            }
            else if (timePassed < 0) {
                progress = 0;
            }
            else {
                progress = timePassed / duration;
                progress = progress > 1 ? 1 : progress;
                if (!textBlock.ended) {
                    textBlock.progress = progress;
                    if (self.layerBased) {
                        [self updateViewStateWithTextBlock:textBlock];
                    }
                    else {
                        CGRect dityRect = [self redrawAreaForRect:self.bounds textBlock:textBlock];
                        [self setNeedsDisplayInRect:dityRect];
                    }
                }
            }
            textBlock.progress = progress;
        }];
    }
}

- (void) _removeAllTextLayers
{
    NSMutableArray *toDelete = [NSMutableArray arrayWithCapacity:1];
    for (CALayer *layer in self.layer.sublayers) {
        [toDelete addObject:layer];
    }
    
    for (CALayer *layer in toDelete) {
        [layer removeFromSuperlayer];
    }
}

#pragma mark layout related

- (void) sizeToFit
{
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), self.layoutTool.estimatedHeight);
}


- (CGSize) intrinsicContentSize
{
    return CGSizeMake(self.preferredMaxLayoutWidth > 0 ? self.preferredMaxLayoutWidth : 200, self.layoutTool.estimatedHeight);
}


- (void) _layoutForChangedString
{
    [self.layoutTool cleanLayout];
    if (!_attributedString) {
        _attributedString = [[NSAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName : self.font}];
    }
    self.layoutTool.layerBased = self.layerBased;
    
    if (self.layerBased) {
        [self _removeAllTextLayers];
    }
    
    [self.layoutTool layoutWithAttributedString:self.attributedString constainedToSize:self.frame.size];
    __block CGFloat maxDuration = 0;
    [self.layoutTool.textBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ZCTextBlock *textBlock = obj;
        [self textBlockAttributesInit:textBlock];
        
        CGFloat duration = textBlock.duration > 0 ? textBlock.duration : self.animationDuration;
        CGFloat startDelay = textBlock.startDelay > 0 ? textBlock.startDelay : idx * self.animationDelay;
        CGFloat realStartDelay = startDelay + duration;
        if (realStartDelay > maxDuration) {
            maxDuration = realStartDelay;
        }

        if (self.layerBased) {
            [self.layer addSublayer:textBlock.textBlockLayer];
        }
    }];
    
    self.animationDurationTotal = maxDuration;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        [self invalidateIntrinsicContentSize]; //reset intrinsicContentSize
    }
}

#pragma Label related

- (void) setNeedsDisplayInRect:(CGRect)rect
{
    if (self.layerBased) {
        return;
    }
    if (self.onlyDrawDirtyArea) {
        [super setNeedsDisplayInRect:rect];
    }
    else {
        [super setNeedsDisplay];
    }
}

- (void) setNeedsDisplay
{
    if (self.layerBased) {
        return;
    }
    else {
        [super setNeedsDisplay];
    }
}

- (void) setAttributedString:(NSAttributedString *)attributedString
{
    _attributedString = attributedString;
    if ([attributedString length] < 1) {
        return;
    }
    NSDictionary *attributes = [attributedString attributesAtIndex:0 effectiveRange:NULL];
    UIFont *font = [attributes objectForKey:NSFontAttributeName];
    UIColor *color = [attributes objectForKey:NSForegroundColorAttributeName];
    if (font) {
        _font = font;
    }
    if (color) {
        _textColor = color;
    }
    [self _layoutForChangedString];
    [self setNeedsDisplay];
}

- (void) setFont:(UIFont *)font
{
    _font = font;
    [self _layoutForChangedString];
    [self setNeedsDisplay];
}

- (void) setText:(NSString *)text
{
    _text = text;
    [self _layoutForChangedString];
    [self setNeedsDisplay];    
}

- (void) setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self setNeedsDisplay]; //no layout change
}

- (void) setUseDefaultDrawing:(BOOL)useDefaultDrawing
{
    _useDefaultDrawing = useDefaultDrawing;
    [self setNeedsDisplay];
}


- (void) startAppearAnimation
{
    self.animatingAppear = YES;
    self.animationTime = 0;
    self.useDefaultDrawing = NO;
    self.displayLink.paused = NO;
    self.animationStarTime = 0;
    [self setNeedsDisplay];
}

- (void) startDisappearAnimation
{
    self.animatingAppear = NO;
    self.animationTime = 0;
    self.useDefaultDrawing = NO;
    self.displayLink.paused = NO;
    self.animationStarTime = 0;
    [self setNeedsDisplay]; //draw all rects
}


- (void) stopAnimation
{
    self.animationTime = 0;
    self.displayLink.paused = YES;
}

- (void) setDebugTextBlockBounds:(BOOL)drawsCharRect
{
    _debugTextBlockBounds = drawsCharRect;
    [self setNeedsDisplay];
}

- (void) setLayerBased:(BOOL)layerBased
{
    _layerBased = layerBased;
    [self setNeedsDisplay]; //blank draw rect
    if (!layerBased) {
        [self _removeAllTextLayers];
    }
}


#pragma mark Custom Drawing

- (void) textBlockAttributesInit: (ZCTextBlock *) textBlock
{
    //override this in subclass if necessary
}


- (CGRect) redrawAreaForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock
{
    return  textBlock.charRect;
}

- (void) appearStateDrawingForRect:(CGRect)rect textBlock: (ZCTextBlock *)textBlock
{
    CGFloat realProgress = [ZCEasingUtil bounceWithStiffness:0.01 numberOfBounces:1 time:textBlock.progress shake:NO shouldOvershoot:NO];
    if (textBlock.progress <= 0.0f) {
        return; 
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    if (self.appearDirection == ZCAnimatedLabelAppearDirectionFromCenter) {
        CGContextTranslateCTM(context, CGRectGetMidX(textBlock.charRect), CGRectGetMidY(textBlock.charRect));
        CGContextScaleCTM(context, realProgress, realProgress);
        CGRect rotatedRect = CGRectMake(-textBlock.charRect.size.width / 2, - textBlock.charRect.size.height / 2, textBlock.charRect.size.width, textBlock.charRect.size.height);
        [textBlock.derivedAttributedString drawInRect:rotatedRect];
    }
    else if (self.appearDirection == ZCAnimatedLabelAppearDirectionFromTop) {
        CGContextTranslateCTM(context, CGRectGetMidX(textBlock.charRect), CGRectGetMinY(textBlock.charRect));
        CGContextScaleCTM(context, realProgress, realProgress);
        CGRect rotatedRect = CGRectMake(-textBlock.charRect.size.width / 2,0, textBlock.charRect.size.width, textBlock.charRect.size.height);
        [textBlock.derivedAttributedString drawInRect:rotatedRect];
    }
    else if (self.appearDirection == ZCAnimatedLabelAppearDirectionFromTopLeft) {
        CGContextTranslateCTM(context, CGRectGetMinX(textBlock.charRect), CGRectGetMinY(textBlock.charRect));
        CGContextScaleCTM(context, realProgress, realProgress);
        CGRect rotatedRect = CGRectMake(0, 0, textBlock.charRect.size.width, textBlock.charRect.size.height);
        [textBlock.derivedAttributedString drawInRect:rotatedRect];
    }
    else if (self.appearDirection == ZCAnimatedLabelAppearDirectionFromBottom) {
        CGContextTranslateCTM(context, CGRectGetMidX(textBlock.charRect), CGRectGetMaxY(textBlock.charRect));
        CGContextScaleCTM(context, realProgress, realProgress);
        CGRect rotatedRect = CGRectMake(-textBlock.charRect.size.width / 2, - textBlock.charRect.size.height, textBlock.charRect.size.width, textBlock.charRect.size.height);
        [textBlock.derivedAttributedString drawInRect:rotatedRect];
    }
    CGContextRestoreGState(context);
}

- (void) disappearStateDrawingForRect:(CGRect)rect textBlock:(ZCTextBlock *)textBlock
{
    textBlock.progress = 1 - textBlock.progress; //default implementation, might not looks right
    [self appearStateDrawingForRect:rect textBlock:textBlock];
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.layerBased) {
        return;
    }

    if (self.debugRedraw) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat hue = ( arc4random() % 256 / 256.0 );
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);        
    }
    
    for (ZCTextBlock *textBlock in self.layoutTool.textBlocks) {
        if (!CGRectIntersectsRect(rect, textBlock.charRect)) {
            continue; //skip this text redraw
        }

        if (self.debugTextBlockBounds) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
            CGContextAddRect(context, textBlock.charRect);
            CGContextStrokePath(context);
        }
        
        if (self.useDefaultDrawing) {
            if (self.animatingAppear) {
                [textBlock.derivedAttributedString drawInRect:textBlock.charRect];
            }            
        }
        else {
            if (self.animatingAppear) {
                [self appearStateDrawingForRect:rect textBlock:textBlock];
            }
            if (!self.animatingAppear) {
                [self disappearStateDrawingForRect:rect textBlock:textBlock];
            }
        }
    }

    if (self.useDefaultDrawing) {
        [self.layoutTool cleanLayout];
    }
}


#pragma mark Custom View Attribute Changes

- (void) updateViewStateWithTextBlock: (ZCTextBlock *) textBlock
{
    if (self.animatingAppear) {
        [self appearStateLayerChangesForTextBlock:textBlock];
    }
    if (!self.animatingAppear) {
        [self disappearLayerStateChangesForTextBlock:textBlock];
    }
}

- (void) appearStateLayerChangesForTextBlock: (ZCTextBlock *) textBlock
{
    
}

- (void) disappearLayerStateChangesForTextBlock: (ZCTextBlock *) textBlock
{
    
}


@end
