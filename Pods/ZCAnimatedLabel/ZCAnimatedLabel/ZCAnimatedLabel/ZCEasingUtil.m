//
//  ZCEasingUtil.m
//  ZCAnimatedLabel
//
//  Contains code from
//  https://github.com/khanlou/SKBounceAnimation
//
//  Created by Chen Zhang on 2/15/15.
//  Copyright (c) 2015 somewhere. All rights reserved.
//

#import "ZCEasingUtil.h"

CGFloat ZCQuadraticEaseIn(CGFloat p)
{
    return p * p;
}

CGFloat ZCQuadraticEaseOut(CGFloat p)
{
    return -(p * (p - 2));
}


CGFloat ZCBounceEaseOut(CGFloat p)
{
    if(p < 1/2.75)
    {
        return (7.5625 * p * p);
    }
    else if(p < 2/2.75)
    {
        p-=(1.5/2.75);
        return (7.5625 *  p *p + .75);
    }
    else if(p < 9/10.0)
    {
        p-=(2.25/2.75);
        return (7.5625 * p * p + .9375);
    }
    else
    {
        p-=(2.625/2.75);
        return (7.5625* p * p + .984375);
    }
}

CGFloat ZCBounceEaseIn(CGFloat p)
{
    return 1 - ZCBounceEaseOut(1 - p);
}

CGFloat ZCBackEaseIn(CGFloat p)
{
    CGFloat s = 1.70158;
    return (p * p * ((s + 1.0) * p - s));
}

CGFloat ZCBackEaseOut(CGFloat p)
{
    CGFloat s = 1.70158;
    CGFloat p2 = p - 1.0;
    return (p2 * p2 * ((s + 1.0) * p2 + s) + 1.0);
}



@implementation ZCEasingUtil

+ (CGFloat) bounceWithStiffness: (CGFloat) stiffness numberOfBounces: (CGFloat) numberOfBounces time: (CGFloat) progress shake: (BOOL) shake shouldOvershoot: (BOOL) shouldOvershoot startValue: (CGFloat) start endValue: (CGFloat) end {
    
    CGFloat startValue = 0.0f;
    CGFloat endValue = 1.0f;
    CGFloat alpha = 0.0f;
    if (startValue == endValue) {
        alpha = log2f(stiffness);
    } else {
        alpha = log2f(stiffness / fabs(endValue - startValue));
    }
    if (alpha > 0) {
        alpha = -1.0f * alpha;
    }
    CGFloat numberOfPeriods = numberOfBounces / 2 + 0.5;
    CGFloat omega = numberOfPeriods * 2 * M_PI;
    
    CGFloat t = progress;
    
    CGFloat oscillationComponent;
    CGFloat coefficient;
    
    //y = A * e ^ (-alpha * t) * cos(omega * t)
    
    if (shake) {
        oscillationComponent =  sin(omega * t);
    } else {
        oscillationComponent =  cos(omega * t);
    }
    
    coefficient =  (startValue - endValue);
    
    if (!shouldOvershoot) {
        oscillationComponent =  fabs(oscillationComponent);
    }
    
    CGFloat value = coefficient * pow(2.71, alpha * t) * oscillationComponent + endValue;
    return (end - start) * value + start;
}

+ (CGFloat) bounceWithStartValue: (CGFloat) startValue endValue: (CGFloat) endValue time: (CGFloat) progress
{
    return [ZCEasingUtil bounceWithStiffness:5 numberOfBounces:1 time:progress shake:NO shouldOvershoot:YES startValue:startValue endValue:endValue];
}

+ (CGFloat) bounceWithStiffness: (CGFloat) stiffness numberOfBounces: (CGFloat) numberOfBounces time: (CGFloat) progress shake: (BOOL) shake shouldOvershoot: (BOOL) shouldOvershoot {
    return [ZCEasingUtil bounceWithStiffness:stiffness numberOfBounces:numberOfBounces time:progress shake:shake shouldOvershoot:shouldOvershoot startValue:0 endValue:1];
}

+ (CGFloat) easeInWithStartValue: (CGFloat) startValue endValue: (CGFloat) endValue time:(CGFloat) progress
{
    return startValue + (endValue - startValue) * ZCQuadraticEaseIn(progress);
}

+ (CGFloat) easeOutWithStartValue: (CGFloat) startValue endValue: (CGFloat) endValue time:(CGFloat) progress
{
    return startValue + (endValue - startValue) * ZCQuadraticEaseOut(progress);
}

+ (CGFloat) easeOutBounceStartValue: (CGFloat) startValue endValue: (CGFloat) endValue time: (CGFloat) progress
{
    return startValue + (endValue - startValue) * ZCBounceEaseOut(progress);
}

+ (CGFloat) easeInBounceStartValue: (CGFloat) startValue endValue: (CGFloat) endValue time: (CGFloat) progress
{
    return startValue + (endValue - startValue) * ZCBounceEaseIn(progress);
}

+ (CGFloat) easeOutBackStartValue: (CGFloat) startValue endValue: (CGFloat) endValue time: (CGFloat) progress
{
    return startValue + (endValue - startValue) * ZCBackEaseOut(progress);
}

+ (CGFloat) easeInBackStartValue: (CGFloat) startValue endValue: (CGFloat) endValue time: (CGFloat) progress
{
    return startValue + (endValue - startValue) * ZCBackEaseIn(progress);
}

@end
