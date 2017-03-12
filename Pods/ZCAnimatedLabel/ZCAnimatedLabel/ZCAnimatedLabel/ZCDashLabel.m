//
//  ZCDashLabel.m
//  ZCAnimatedLabel
//
//  Created by Chen Zhang on 3/25/15.
//  Copyright (c) 2015 overboming. All rights reserved.
//

#import "ZCDashLabel.h"


/**
 * code from AGGeometryKit https://github.com/hfossli/AGGeometryKit/
 */
@implementation CALayer (Quadrilateral)

- (CATransform3D)transformToFitQuadTopLeft:(CGPoint)tl topRight:(CGPoint)tr bottomLeft:(CGPoint)bl bottomRight:(CGPoint)br
{
    CGRect boundingBox = [[self class] boundingBoxForQuadTR:tr tl:tl bl:bl br:br];
    self.transform = CATransform3DIdentity; // keeps current transform from interfering
    self.frame = boundingBox;
    
    CGPoint frameTopLeft = boundingBox.origin;
    CATransform3D transform = [[self class] rectToQuad:self.bounds
                                                quadTL:CGPointMake(tl.x-frameTopLeft.x, tl.y-frameTopLeft.y)
                                                quadTR:CGPointMake(tr.x-frameTopLeft.x, tr.y-frameTopLeft.y)
                                                quadBL:CGPointMake(bl.x-frameTopLeft.x, bl.y-frameTopLeft.y)
                                                quadBR:CGPointMake(br.x-frameTopLeft.x, br.y-frameTopLeft.y)];
    
    //  To account for anchor point, we must translate, transform, translate
    CGPoint anchorPoint = self.position;
    CGPoint anchorOffset = CGPointMake(anchorPoint.x - boundingBox.origin.x, anchorPoint.y - boundingBox.origin.y);
    CATransform3D transPos = CATransform3DMakeTranslation(anchorOffset.x, anchorOffset.y, 0.);
    CATransform3D transNeg = CATransform3DMakeTranslation(-anchorOffset.x, -anchorOffset.y, 0.);
    CATransform3D fullTransform = CATransform3DConcat(CATransform3DConcat(transPos, transform), transNeg);
    
    //  Now we set our transform
    self.transform = fullTransform;
    return fullTransform;
}

+ (CGRect)boundingBoxForQuadTR:(CGPoint)tr tl:(CGPoint)tl bl:(CGPoint)bl br:(CGPoint)br
{
    CGRect boundingBox = CGRectZero;
    
    CGFloat xmin = MIN(MIN(MIN(tr.x, tl.x), bl.x),br.x);
    CGFloat ymin = MIN(MIN(MIN(tr.y, tl.y), bl.y),br.y);
    CGFloat xmax = MAX(MAX(MAX(tr.x, tl.x), bl.x),br.x);
    CGFloat ymax = MAX(MAX(MAX(tr.y, tl.y), bl.y),br.y);
    
    boundingBox.origin.x = xmin;
    boundingBox.origin.y = ymin;
    boundingBox.size.width = xmax - xmin;
    boundingBox.size.height = ymax - ymin;
    
    return boundingBox;
}

+ (CATransform3D)rectToQuad:(CGRect)rect
                     quadTL:(CGPoint)topLeft
                     quadTR:(CGPoint)topRight
                     quadBL:(CGPoint)bottomLeft
                     quadBR:(CGPoint)bottomRight
{
    return [self rectToQuad:rect quadTLX:topLeft.x quadTLY:topLeft.y quadTRX:topRight.x quadTRY:topRight.y quadBLX:bottomLeft.x quadBLY:bottomLeft.y quadBRX:bottomRight.x quadBRY:bottomRight.y];
}

+ (CATransform3D)rectToQuad:(CGRect)rect
                    quadTLX:(CGFloat)x1a
                    quadTLY:(CGFloat)y1a
                    quadTRX:(CGFloat)x2a
                    quadTRY:(CGFloat)y2a
                    quadBLX:(CGFloat)x3a
                    quadBLY:(CGFloat)y3a
                    quadBRX:(CGFloat)x4a
                    quadBRY:(CGFloat)y4a
{
    CGFloat X = rect.origin.x;
    CGFloat Y = rect.origin.y;
    CGFloat W = rect.size.width;
    CGFloat H = rect.size.height;
    
    CGFloat y21 = y2a - y1a;
    CGFloat y32 = y3a - y2a;
    CGFloat y43 = y4a - y3a;
    CGFloat y14 = y1a - y4a;
    CGFloat y31 = y3a - y1a;
    CGFloat y42 = y4a - y2a;
    
    CGFloat a = -H*(x2a*x3a*y14 + x2a*x4a*y31 - x1a*x4a*y32 + x1a*x3a*y42);
    CGFloat b = W*(x2a*x3a*y14 + x3a*x4a*y21 + x1a*x4a*y32 + x1a*x2a*y43);
    CGFloat c = H*X*(x2a*x3a*y14 + x2a*x4a*y31 - x1a*x4a*y32 + x1a*x3a*y42) - H*W*x1a*(x4a*y32 - x3a*y42 + x2a*y43) - W*Y*(x2a*x3a*y14 + x3a*x4a*y21 + x1a*x4a*y32 + x1a*x2a*y43);
    
    CGFloat d = H*(-x4a*y21*y3a + x2a*y1a*y43 - x1a*y2a*y43 - x3a*y1a*y4a + x3a*y2a*y4a);
    CGFloat e = W*(x4a*y2a*y31 - x3a*y1a*y42 - x2a*y31*y4a + x1a*y3a*y42);
    CGFloat f = -(W*(x4a*(Y*y2a*y31 + H*y1a*y32) - x3a*(H + Y)*y1a*y42 + H*x2a*y1a*y43 + x2a*Y*(y1a - y3a)*y4a + x1a*Y*y3a*(-y2a + y4a)) - H*X*(x4a*y21*y3a - x2a*y1a*y43 + x3a*(y1a - y2a)*y4a + x1a*y2a*(-y3a + y4a)));
    
    CGFloat g = H*(x3a*y21 - x4a*y21 + (-x1a + x2a)*y43);
    CGFloat h = W*(-x2a*y31 + x4a*y31 + (x1a - x3a)*y42);
    CGFloat i = W*Y*(x2a*y31 - x4a*y31 - x1a*y42 + x3a*y42) + H*(X*(-(x3a*y21) + x4a*y21 + x1a*y43 - x2a*y43) + W*(-(x3a*y2a) + x4a*y2a + x2a*y3a - x4a*y3a - x2a*y4a + x3a*y4a));
    
    const double kEpsilon = 0.0001;
    
    if(fabs(i) < kEpsilon)
    {
        i = kEpsilon* (i > 0 ? 1.0 : -1.0);
    }
    
    CATransform3D transform = {a/i, d/i, 0, g/i, b/i, e/i, 0, h/i, 0, 0, 1, 0, c/i, f/i, 0, 1.0};
    
    return transform;
}

@end


@implementation ZCDashLabel

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.onlyDrawDirtyArea = NO;
        self.layerBased = YES;
    }
    return self;
}

- (void) textBlockAttributesInit:(ZCTextBlock *)textBlock
{
    ZCTextBlockLayer *layer = textBlock.textBlockLayer;
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    layer.backgroundColor = [UIColor clearColor].CGColor;
    [layer setNeedsDisplay];
    layer.opacity = 0;
    layer.anchorPoint = CGPointMake(0, 0);
    layer.position = CGPointMake(self.bounds.size.width, textBlock.textBlockLayer.position.y);
    [CATransaction commit];
}


- (void) appearStateLayerChangesForTextBlock: (ZCTextBlock *) textBlock
{
    if (textBlock.progress <= 0) {
        return;
    }
    //0~0.5, run
    CGFloat realProgress = ([ZCEasingUtil easeOutWithStartValue:0 endValue:1 time:textBlock.progress < 0.5 ? textBlock.progress * 2 : 1]);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CGPoint shouldBePosition = CGPointMake(CGRectGetMinX(textBlock.charRect), CGRectGetMinY(textBlock.charRect));
    CALayer *textLayer = textBlock.textBlockLayer;
    textLayer.position = CGPointMake(shouldBePosition.x + (1 - realProgress) * (self.bounds.size.width - shouldBePosition.x), shouldBePosition.y);
    textLayer.opacity = (textBlock.progress < 0.5) ? [ZCEasingUtil easeInWithStartValue:0 endValue:1 time:textBlock.progress * 2] : 1;
    CGRect rect = CGRectMake(textLayer.position.x, textLayer.position.y, textBlock.charRect.size.width, textBlock.charRect.size.height);
    //0~0.5 dash in
    //0.5~1.0 break
    CGFloat horizontalShiftValue = 0;
    if (textBlock.progress < 0.5) {
        horizontalShiftValue = [ZCEasingUtil easeOutWithStartValue:1 endValue:0.6 time:textBlock.progress * 2];
    }
    else {
        horizontalShiftValue = [ZCEasingUtil bounceWithStiffness:5 numberOfBounces:1 time:(textBlock.progress - 0.5) / 0.5 shake:NO shouldOvershoot:YES startValue:0.6 endValue:0];
    }
    horizontalShiftValue *=  textBlock.derivedFont.pointSize * 0.4;

    textBlock.textBlockLayer.transform = [textBlock.textBlockLayer
                                          transformToFitQuadTopLeft:CGPointMake(rect.origin.x + horizontalShiftValue, rect.origin.y)
                                                           topRight:CGPointMake(rect.origin.x + rect.size.width + horizontalShiftValue , rect.origin.y)
                                                         bottomLeft:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)
                                                        bottomRight:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
    [CATransaction commit];
}



@end
