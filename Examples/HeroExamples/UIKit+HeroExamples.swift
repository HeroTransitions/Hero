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

public extension UIView {
  @IBInspectable public var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }

    set {
      layer.cornerRadius = newValue
    }
  }
  @IBInspectable public var shadowRadius: CGFloat {
    get {
      return layer.shadowRadius
    }

    set {
      layer.shadowRadius = newValue
    }
  }
  @IBInspectable public var shadowOpacity: Float {
    get {
      return layer.shadowOpacity
    }

    set {
      layer.shadowOpacity = newValue
    }
  }
  @IBInspectable public var shadowColor: UIColor? {
    get {
      return layer.shadowColor != nil ? UIColor(cgColor: layer.shadowColor!) : nil
    }

    set {
      layer.shadowColor = newValue?.cgColor
    }
  }
  @IBInspectable public var shadowOffset: CGSize {
    get {
      return layer.shadowOffset
    }

    set {
      layer.shadowOffset = newValue
    }
  }
  @IBInspectable public var zPosition: CGFloat {
    get {
      return layer.zPosition
    }

    set {
      layer.zPosition = newValue
    }
  }
}

func viewController(forStoryboardName: String) -> UIViewController {
  return UIStoryboard(name: forStoryboardName, bundle: nil).instantiateInitialViewController()!
}

class TemplateImageView: UIImageView {
  @IBInspectable var templateImage: UIImage? {
    didSet {
      image = templateImage?.withRenderingMode(.alwaysTemplate)
    }
  }
}
