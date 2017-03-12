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

class ImageCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
}

class ScrollingImageCell: UICollectionViewCell {
  var imageView: UIImageView!
  var scrollView: UIScrollView!
  var dTapGR: UITapGestureRecognizer!
  var image: UIImage? {
    get { return imageView.image }
    set {
      imageView.image = newValue
      setNeedsLayout()
    }
  }
  var topInset: CGFloat = 0 {
    didSet {
      centerIfNeeded()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    scrollView = UIScrollView(frame: bounds)
    imageView = UIImageView(frame: bounds)
    imageView.contentMode = .scaleAspectFill
    scrollView.addSubview(imageView)
    scrollView.maximumZoomScale = 3
    scrollView.delegate = self
    scrollView.contentMode = .center
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    if #available(iOS 9.0, *) {
      scrollView.panGestureRecognizer.allowedTouchTypes = [ NSNumber(value:UITouchType.indirect.rawValue) ]
    }
    addSubview(scrollView)

    dTapGR = UITapGestureRecognizer(target: self, action: #selector(doubleTap(gr:)))
    dTapGR.numberOfTapsRequired = 2
    addGestureRecognizer(dTapGR)
  }

  func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
    var zoomRect = CGRect.zero
    zoomRect.size.height = imageView.frame.size.height / scale
    zoomRect.size.width  = imageView.frame.size.width  / scale
    let newCenter = imageView.convert(center, from: scrollView)
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
    return zoomRect
  }

  func doubleTap(gr: UITapGestureRecognizer) {
    if scrollView.zoomScale == 1 {
      scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: gr.location(in: gr.view)), animated: true)
    } else {
      scrollView.setZoomScale(1, animated: true)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    scrollView.frame = bounds
    let size: CGSize
    if let image = imageView.image {
      let containerSize = CGSize(width: bounds.width, height: bounds.height - topInset)
      if containerSize.width / containerSize.height < image.size.width / image.size.height {
        size = CGSize(width: containerSize.width, height: containerSize.width * image.size.height / image.size.width )
      } else {
        size = CGSize(width: containerSize.height * image.size.width / image.size.height, height: containerSize.height )
      }
    } else {
      size = CGSize(width: bounds.width, height: bounds.width)
    }
    imageView.frame = CGRect(origin: .zero, size: size)
    scrollView.contentSize = size
    centerIfNeeded()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    scrollView.setZoomScale(1, animated: false)
  }

  func centerIfNeeded() {
    var inset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    if scrollView.contentSize.height < scrollView.bounds.height - topInset {
      let insetV = (scrollView.bounds.height - topInset - scrollView.contentSize.height)/2
      inset.top += insetV
      inset.bottom = insetV
    }
    if scrollView.contentSize.width < scrollView.bounds.width {
      let insetV = (scrollView.bounds.width - scrollView.contentSize.width)/2
      inset.left = insetV
      inset.right = insetV
    }
    scrollView.contentInset = inset
  }
}

extension ScrollingImageCell: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    centerIfNeeded()
  }
}
