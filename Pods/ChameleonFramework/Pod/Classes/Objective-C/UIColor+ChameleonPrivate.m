//
//  UIColor+ChameleonPrivate.m
//  Chameleon
//
//  Created by Vicc Alexander on 6/6/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import "UIColor+ChameleonPrivate.h"

@implementation UIColor (ChameleonPrivate)

@dynamic count;

#pragma mark - Associated Objects Methods

- (void)setCount:(NSUInteger)count {
    objc_setAssociatedObject(self, @selector(count), [NSNumber numberWithUnsignedInteger:count], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)count {
    NSNumber *number = objc_getAssociatedObject(self, @selector(count));
    return [number unsignedIntegerValue];
}

#pragma mark - Class Methods

// Would not have been possible without - http://stackoverflow.com/a/1262893
+ (UIColor *)colorFromImage:(UIImage *)image atPoint:(CGPoint)point {
    
    //Encapsulate our image
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    //Specify the colorspace we're in
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //Extract the data we need
    unsigned char *rawData = calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow,
                                                 colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    //Release colorspace
    CGColorSpaceRelease(colorSpace);
    
    //Draw and release image
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    //rawData now contains the image data in RGBA8888
    NSInteger byteIndex = (bytesPerRow * point.y) + (point.x * bytesPerPixel);
    
    //Define our RGBA values
    CGFloat red = (rawData[byteIndex] * 1.f) / 255.f;
    CGFloat green = (rawData[byteIndex + 1] * 1.f) / 255.f;
    CGFloat blue = (rawData[byteIndex + 2] * 1.f) / 255.f;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.f;
    
    //Free our rawData
    free(rawData);
    
    //Return color
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)colorWithMinimumSaturation:(CGFloat)saturation {
    if (!self)
        return nil;
    
    CGFloat h, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    
    if (s < saturation)
        return [UIColor colorWithHue:h saturation:saturation brightness:b alpha:a];
    
    return self;
}

#pragma mark - Instance Methods

- (BOOL)isDistinct:(UIColor *)color {
    
    if (!self || !color) {
        return NO;
    }
    
    CGFloat r, g, b, a;
    CGFloat rc, gc, bc, ac;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    [color getRed:&rc green:&gc blue:&bc alpha:&ac];
    
    CGFloat threshold = 0.25f;
    
    if (fabs(r - rc) > threshold || fabs(g - gc) > threshold ||
        
        fabs(b - bc) > threshold || fabs(a - ac) > threshold) {
        
        // Check for grays
        if (fabs(r - g) < 0.03f && fabs(r - b) < 0.03f) {
            
            if (fabs(rc - gc) < 0.03f && (fabs(rc - bc) < 0.03f)) {
                return NO;
            }
            
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)getValueForX:(CGFloat *)X valueForY:(CGFloat *)Y valueForZ:(CGFloat *)Z alpha:(CGFloat *)alpha{
    
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        
        //Get RGB values from the input color
        CGFloat red = 0, green = 0, blue = 0, alpha1 = 0;
        [self getRed:&red green:&green blue:&blue alpha:&alpha1];
        
        //Run our input color's RGB values through the XYZ algorithm to convert them into XYZ values
        NSArray *XYZValues = [self arrayOfXYZValuesForR:red G:green B:blue A:alpha1];
        *X = [XYZValues[0] floatValue];
        *Y = [XYZValues[1] floatValue];
        *Z = [XYZValues[2] floatValue];
        *alpha = [XYZValues[3] floatValue];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)getLightness:(CGFloat *)L valueForA:(CGFloat *)A valueForB:(CGFloat *)B alpha:(CGFloat *)alpha {
    
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        
        //Get RGB values from the input color
        CGFloat red = 0, green = 0, blue = 0, alpha1 = 0;
        [self getRed:&red green:&green blue:&blue alpha:&alpha1];
        
        //Run our input color's RGB values through the XYZ algorithm to convert them into XYZ values
        NSArray *XYZValues = [self arrayOfXYZValuesForR:red G:green B:blue A:alpha1];
        CGFloat X = [XYZValues[0] floatValue];
        CGFloat Y = [XYZValues[1] floatValue];
        CGFloat Z = [XYZValues[2] floatValue];
        
        if (L != nil && A != nil && B != nil) {
            //Run our new XYZ values through our LAB algorithm to convert them into LAB values
            NSArray *LABValues = [self arrayOfLABValuesForX:X Y:Y Z:Z alpha:alpha1];
            *L = [LABValues[0] floatValue];
            *A = [LABValues[1] floatValue];
            *B = [LABValues[2] floatValue];
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Internal Helper Methods

- (NSArray *)arrayOfXYZValuesForR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha {
    
    /*
     Let's begin by converting from RGB to sRGB.
     We're going to use the Reverse Transformation Equation.
     http://en.wikipedia.org/wiki/SRGB
     */
    
    void (^sRGB)(CGFloat *C);
    sRGB = ^(CGFloat *C) {
        if (*C > 0.04045) {
            *C = pow(((*C + 0.055)/ (1 + 0.055)), 2.40);
        } else {
            *C /= 12.92;
        }
    };
    
    sRGB(&red);
    sRGB(&green);
    sRGB(&blue);
    
    /*
     Now we're going to convert to XYZ values, using a matrix multiplication of the linear values
     http://upload.wikimedia.org/math/4/3/3/433376fc18cccd887758beffb7e7c625.png
     */
    
    CGFloat X = (red * 0.4124) + (green * 0.3576) + (blue * 0.1805);
    CGFloat Y = (red * 0.2126) + (green * 0.7152) + (blue * 0.0722);
    CGFloat Z = (red * 0.0193) + (green * 0.1192) + (blue * 0.9505);
    
    X *= 100;
    Y *= 100;
    Z *= 100;
    
    return @[@(X), @(Y), @(Z), @(alpha)];
}

- (NSArray *)arrayOfLABValuesForX:(CGFloat)X Y:(CGFloat)Y Z:(CGFloat)Z alpha:(CGFloat)alpha {
    
    /*
     The corresponding original XYZ values are such that white is D65 with unit luminance (X,Y,Z = 0.9505, 1.0000, 1.0890).
     Calculations are also to assume the 2° standard colorimetric observer.
     D65: http://en.wikipedia.org/wiki/CIE_Standard_Illuminant_D65
     Standard Colorimetric Observer: http://en.wikipedia.org/wiki/Standard_colorimetric_observer#CIE_standard_observer
     
     Since we mutiplied our XYZ values by 100 to produce a percentage we should also multiply our unit luminance values by 100.
     */
    
    X /= (0.9505 * 100);
    Y /= (1.0000 * 100);
    Z /= (1.0890 * 100);
    
    /*
     Next we need to use the forward transformation function for CIELAB-CIEXYZ conversions
     Function: http://upload.wikimedia.org/math/e/5/1/e513d25d50d406bfffb6ed3c854bd8a4.png
     */
    
    void (^XYZtoLAB)(CGFloat *f);
    XYZtoLAB = ^(CGFloat *f) {
        if ((*f > pow((6.0/29.0), 3.0)) ) {
            *f = pow(*f, 1.0/3.0);
        } else {
            *f = (1/3)*pow((29.0/6.0), 2.0) * *f + 4/29.0;
        }
    };
    
    XYZtoLAB(&X);
    XYZtoLAB(&Y);
    XYZtoLAB(&Z);
    
    /*
     Next we get our LAB values using the following equations and the results from the function above
     http://upload.wikimedia.org/math/0/0/6/006164b74314e2fdcdc34ac9d0aa6fe4.png
     */
    
    CGFloat L = (116 * Y) - 16;
    CGFloat A = 500 * (X - Y);
    CGFloat B = 200 * (Y - Z);
    
    
    return @[@(L), @(A), @(B), @(alpha)];
}

@end
