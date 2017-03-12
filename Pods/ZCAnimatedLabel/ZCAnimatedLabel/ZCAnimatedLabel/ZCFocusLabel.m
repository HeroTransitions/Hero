//
//  ZCFocusLabel.m
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 2/28/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import "ZCFocusLabel.h"
#import <Accelerate/Accelerate.h>


@implementation UIImage (FXBlurView)

- (UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor
{
    //image must be nonzero size
    if (floorf(self.size.width) * floorf(self.size.height) <= 0.0f) return self;
    
    //boxsize must be an odd integer
    uint32_t boxSize = (uint32_t)(radius * self.scale);
    if (boxSize % 2 == 0) boxSize ++;
    
    //create image buffers
    CGImageRef imageRef = self.CGImage;
    vImage_Buffer buffer1, buffer2;
    buffer1.width = buffer2.width = CGImageGetWidth(imageRef);
    buffer1.height = buffer2.height = CGImageGetHeight(imageRef);
    buffer1.rowBytes = buffer2.rowBytes = CGImageGetBytesPerRow(imageRef);
    size_t bytes = buffer1.rowBytes * buffer1.height;
    buffer1.data = malloc(bytes);
    buffer2.data = malloc(bytes);
    
    //create temp buffer
    void *tempBuffer = malloc((size_t)vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, NULL, 0, 0, boxSize, boxSize,
                                                                 NULL, kvImageEdgeExtend + kvImageGetTempBufferSize));
    
    //copy image data
    CFDataRef dataSource = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    memcpy(buffer1.data, CFDataGetBytePtr(dataSource), bytes);
    CFRelease(dataSource);
    
    for (NSUInteger i = 0; i < iterations; i++)
    {
        //perform blur
        vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        //swap buffers
        void *temp = buffer1.data;
        buffer1.data = buffer2.data;
        buffer2.data = temp;
    }
    
    //free buffers
    free(buffer2.data);
    free(tempBuffer);
    
    //create image context from buffer
    CGContextRef ctx = CGBitmapContextCreate(buffer1.data, buffer1.width, buffer1.height,
                                             8, buffer1.rowBytes, CGImageGetColorSpace(imageRef),
                                             CGImageGetBitmapInfo(imageRef));
    
    //apply tint
    if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.0f)
    {
        CGContextSetFillColorWithColor(ctx, [tintColor colorWithAlphaComponent:0.25].CGColor);
        CGContextSetBlendMode(ctx, kCGBlendModePlusLighter);
        CGContextFillRect(ctx, CGRectMake(0, 0, buffer1.width, buffer1.height));
    }
    
    //create image from context
    imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    CGContextRelease(ctx);
    free(buffer1.data);
    return image;
}

@end


@implementation ZCFocusLabel

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.onlyDrawDirtyArea = YES;
    }
    return self;
}

- (void) textBlockAttributesInit:(ZCTextBlock *)textBlock
{
    
}

- (void) appearStateDrawingForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock
{
    CGFloat alpha = [ZCEasingUtil easeInWithStartValue:0 endValue:1 time:textBlock.progress];
    if (textBlock.progress <= 0 || alpha < 0.01) {
        return;
    }
    
    UIGraphicsBeginImageContextWithOptions(textBlock.charRect.size, NO, [UIScreen mainScreen].scale);
    UIColor *color = [textBlock.derivedTextColor colorWithAlphaComponent:alpha];
    textBlock.textColor = color;
    [textBlock.derivedAttributedString drawInRect:CGRectMake(0, 0, textBlock.charRect.size.width, textBlock.charRect.size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    image = [image blurredImageWithRadius:10 * (1 - textBlock.progress) iterations:1 tintColor:nil];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [image drawInRect:textBlock.charRect];
    CGContextRestoreGState(context);
}


@end