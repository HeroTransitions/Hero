// The MIT License (MIT)
//
// Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

/**
 A composable interface for building a string of hero modifiers
 Creating a HeroComposition allows you to chain modifiers to build your animation string
 Extract the modifier string using the .modifier attribute after composing your animation
 
 To create a simple fade and position animation:
 
 HeroComposition().fade().position(0,90).modifier
 
 To create a more complex animation:
 
 HeroComposition().fade().translate(0,150).rotate(-1,0,0).scale(0.8).zPosition(50).zPositionIfMatched(100).modifier
 
 For more documentation on using modifiers, visit:
 
 https://github.com/lkzhao/Hero/wiki/Usage-Guide
 
 */
public class HeroComposition {
    /**
     - Returns: the modifier string for the composition
     */
    fileprivate(set) public var modifier = ""
    
    fileprivate func addModifier(text:String) {
        if modifier.characters.count != 0 {
            modifier += " "
        }
        
        modifier += text
    }
    
    public init() {
        
    }
}

// Basic Modifiers
public extension HeroComposition {
    func fade() -> HeroComposition {
        addModifier(text: "fade")
        return self
    }
    
    func position(x:Float, y:Float) -> HeroComposition {
        addModifier(text: "position(" + String(x) + "," + String(y) + ")")
        return self
    }
    
    func size(w:Float, h:Float) -> HeroComposition {
        addModifier(text: "size(" + String(w) + "," + String(h) + ")")
        return self
    }
    
    func scale(s:Float) -> HeroComposition {
        addModifier(text: "scale(" + String(s) + ")")
        return self
    }
    
    func scale(w:Float, h:Float) -> HeroComposition {
        addModifier(text: "scale(" + String(w) + "," + String(h) + ")")
        return self
    }
    
    func rotate(z:Float) -> HeroComposition {
        addModifier(text: "rotate(" + String(z) + ")")
        return self
    }
    
    func rotate(x:Float, y:Float, z:Float) -> HeroComposition {
        addModifier(text: "rotate(" + String(x) + "," + String(y) + "," + String(z) + ")")
        return self
    }
    
    func perspective(z:Float) -> HeroComposition {
        addModifier(text: "perspective(" + String(z) + ")")
        return self
    }
    
    func translate(x:Float, y:Float) -> HeroComposition {
        addModifier(text: "translate(" + String(x) + "," + String(y) + ")")
        return self
    }
    
    func translate(x:Float, y:Float, z:Float) -> HeroComposition {
        addModifier(text: "translate(" + String(x) + "," + String(y) + "," + String(z) + ")")
        return self
    }
}

public enum HeroCascadeDirection:String {
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
}

public enum HeroCurveName:String {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case standard
    case deceleration
    case acceleration
    case sharp
}

// Advanced Modifiers
public extension HeroComposition {
    func delay(t:Float) -> HeroComposition {
        addModifier(text: "delay(" + String(t) + ")")
        return self
    }
    
    func duration(t:Float) -> HeroComposition {
        addModifier(text: "duration(" + String(t) + ")")
        return self
    }
    
    func curve(name:HeroCurveName) -> HeroComposition {
        addModifier(text: "curve(" + name.rawValue + ")")
        return self
    }
    
    func curve(c1x:Float, c1y:Float, c2x:Float, c2y:Float) -> HeroComposition {
        addModifier(text: "curve(" + String(c1x) + "," + String(c1y) + "," + String(c2x) + "," + String(c2y) + ")")
        return self
    }
    
    func spring(stiffness:Float, damping:Float) -> HeroComposition {
        addModifier(text: "spring(" + String(stiffness) + "," + String(damping) + ")")
        return self
    }
    
    func zPosition(z:Float) -> HeroComposition {
        addModifier(text: "zPosition(" + String(z) + ")")
        return self
    }
    
    func zPositionIfMatched(z:Float) -> HeroComposition {
        addModifier(text: "zPositionIfMatched(" + String(z) + ")")
        return self
    }
    
    func sourceID(from:String) -> HeroComposition {
        addModifier(text: "sourceID(" + from + ")")
        return self
    }
    
    func arc(intensity:Float = 1) -> HeroComposition {
        addModifier(text: "arc(" + String(intensity) + ")")
        return self
    }
    
    func cascade(deltaDelay:Float, direction:HeroCascadeDirection = .topToBottom, initialDelay:Float = 0, forceMatchedToWait:Bool = false) -> HeroComposition {
        addModifier(text: "cascade(" + String(deltaDelay) + "," + direction.rawValue + "," + String(initialDelay) + "," + String(forceMatchedToWait) + ")")
        return self
    }
    
    func clearSubviewModifiers() -> HeroComposition {
        addModifier(text: "clearSubviewModifiers")
        return self
    }
}
