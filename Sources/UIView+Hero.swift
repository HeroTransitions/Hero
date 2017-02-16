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

fileprivate let parameterRegex = "(?:\\-?\\d+(\\.?\\d+)?)|\\w+"
fileprivate let modifiersRegex = "(\\w+)(?:\\(([^\\)]*)\\))?"

public extension UIView {
  private struct AssociatedKeys {
    static var heroID    = "heroID"
    static var heroModifiers = "heroModifers"
    static var heroStoredAlpha = "heroStoredAlpha"
  }

  /**
   **heroID** is the identifier for the view. When doing a transition between two view controllers,
   Hero will search through all the subviews for both view controllers and matches views with the same **heroID**.

   Whenever a pair is discovered,
   Hero will automatically transit the views from source state to the destination state.
   */
  @IBInspectable public var heroID: String? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.heroID) as? String }
    set { objc_setAssociatedObject(self, &AssociatedKeys.heroID, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   Use **heroModifiers** to specify animations alongside the main transition. Checkout `HeroModifier.swift` for available modifiers.
   */
  public var heroModifiers: [HeroModifier]? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.heroModifiers) as? [HeroModifier] }
    set { objc_setAssociatedObject(self, &AssociatedKeys.heroModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   **heroModifierString** provides another way to set **heroModifiers**. It can be assigned through storyboard.
   */
  @IBInspectable public var heroModifierString: String? {
    get { fatalError("Reverse lookup is not supported") }
    set {
      guard let newValue = newValue else {
        heroModifiers = nil
        return
      }
      let modifierString = newValue as NSString
      func matches(for regex: String, text: NSString) -> [NSTextCheckingResult] {
        do {
          let regex = try NSRegularExpression(pattern: regex)
          return regex.matches(in: text as String, range: NSRange(location: 0, length: text.length))
        } catch let error {
          print("invalid regex: \(error.localizedDescription)")
          return []
        }
      }
      var modifiers = [HeroModifier]()
      for r in matches(for: modifiersRegex, text:modifierString) {
        var parameters = [String]()
        if r.numberOfRanges > 2, r.rangeAt(2).location < modifierString.length {
          let parameterString = modifierString.substring(with: r.rangeAt(2)) as NSString
          for r in matches(for: parameterRegex, text: parameterString) {
            parameters.append(parameterString.substring(with: r.range))
          }
        }
        let name = modifierString.substring(with: r.rangeAt(1))
        if let modifier = HeroModifier.from(name: name, parameters: parameters) {
          modifiers.append(modifier)
        }
      }
      heroModifiers = modifiers
    }
  }

  internal func slowSnapshotView() -> UIView {
    UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
    layer.render(in: UIGraphicsGetCurrentContext()!)

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    let imageView = UIImageView(image: image)
    imageView.frame = bounds
    let snapshotView = UIView(frame:bounds)
    snapshotView.addSubview(imageView)
    return snapshotView
  }

  internal var flattenedViewHierarchy: [UIView] {
    return [self] + subviews.flatMap { $0.flattenedViewHierarchy }
  }

  /// Used for .overFullScreen presentation
  internal var heroStoredAlpha: CGFloat? {
    get {
      if let doubleValue = (objc_getAssociatedObject(self, &AssociatedKeys.heroStoredAlpha) as? NSNumber)?.doubleValue {
        return CGFloat(doubleValue)
      }
      return nil
    }
    set {
      if let newValue = newValue {
        objc_setAssociatedObject(self, &AssociatedKeys.heroStoredAlpha, NSNumber(value:newValue.native), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      } else {
        objc_setAssociatedObject(self, &AssociatedKeys.heroStoredAlpha, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
}
