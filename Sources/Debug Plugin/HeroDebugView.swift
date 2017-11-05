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

#if os(iOS)
protocol HeroDebugViewDelegate: class {
  func onProcessSliderChanged(progress: Float)
  func onPerspectiveChanged(translation: CGPoint, rotation: CGFloat, scale: CGFloat)
  func on3D(wants3D: Bool)
  func onDisplayArcCurve(wantsCurve: Bool)
  func onDone()
}

class HeroDebugView: UIView {
  var backgroundView: UIView!
  var debugSlider: UISlider!
  var perspectiveButton: UIButton!
  var doneButton: UIButton!
  var arcCurveButton: UIButton?

  weak var delegate: HeroDebugViewDelegate?
  var panGR: UIPanGestureRecognizer!

  var pinchGR: UIPinchGestureRecognizer!

  var showControls: Bool = false {
    didSet {
      layoutSubviews()
    }
  }

  var showOnTop: Bool = false
  var rotation: CGFloat = π / 6
  var scale: CGFloat = 0.6
  var translation: CGPoint = .zero
  var progress: Float {
    return debugSlider.value
  }

  init(initialProcess: Float, showCurveButton: Bool, showOnTop: Bool) {
    super.init(frame: .zero)
    self.showOnTop = showOnTop
    backgroundView = UIView(frame: .zero)
    backgroundView.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
    backgroundView.layer.shadowColor = UIColor.darkGray.cgColor
    backgroundView.layer.shadowOpacity = 0.3
    backgroundView.layer.shadowRadius = 5
    backgroundView.layer.shadowOffset = CGSize.zero
    addSubview(backgroundView)

    doneButton = UIButton(type: .system)
    doneButton.setTitle("Done", for: .normal)
    doneButton.addTarget(self, action: #selector(onDone), for: .touchUpInside)
    backgroundView.addSubview(doneButton)

    perspectiveButton = UIButton(type: .system)
    perspectiveButton.setTitle("3D View", for: .normal)
    perspectiveButton.addTarget(self, action: #selector(onPerspective), for: .touchUpInside)
    backgroundView.addSubview(perspectiveButton)

    if showCurveButton {
      arcCurveButton = UIButton(type: .system)
      arcCurveButton!.setTitle("Show Arcs", for: .normal)
      arcCurveButton!.addTarget(self, action: #selector(onDisplayArcCurve), for: .touchUpInside)
      backgroundView.addSubview(arcCurveButton!)
    }

    debugSlider = UISlider(frame: .zero)
    debugSlider.layer.zPosition = 1000
    debugSlider.minimumValue = 0
    debugSlider.maximumValue = 1
    debugSlider.addTarget(self, action: #selector(onSlide), for: .valueChanged)
    debugSlider.isUserInteractionEnabled = true
    debugSlider.value = initialProcess
    backgroundView.addSubview(debugSlider)

    panGR = UIPanGestureRecognizer(target: self, action: #selector(pan))
    panGR.delegate = self
    panGR.maximumNumberOfTouches = 1

    addGestureRecognizer(panGR)

    pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
    pinchGR.delegate = self
    addGestureRecognizer(pinchGR)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    var backgroundFrame = bounds
    backgroundFrame.size.height = 72
    if showOnTop {
      backgroundFrame.origin.y = showControls ? 0 : -80
    } else {
      backgroundFrame.origin.y = bounds.maxY - CGFloat(showControls ? 72.0 : -8.0)
    }
    backgroundView.frame = backgroundFrame

    var sliderFrame = bounds.insetBy(dx: 10, dy: 0)
    sliderFrame.size.height = 44
    sliderFrame.origin.y = 28
    debugSlider.frame = sliderFrame

    perspectiveButton.sizeToFit()
    perspectiveButton.frame.origin = CGPoint(x: bounds.maxX - perspectiveButton.bounds.width - 10, y: 4)
    doneButton.sizeToFit()
    doneButton.frame.origin = CGPoint(x: 10, y: 4)
    arcCurveButton?.sizeToFit()
    arcCurveButton?.center = CGPoint(x: center.x, y: doneButton.center.y)
  }

  var startRotation: CGFloat = 0
  @objc public func pan() {
    if panGR.state == .began {
      startRotation = rotation
    }
    rotation = startRotation + panGR.translation(in: nil).x / 150
    if rotation > π {
      rotation -= 2 * π
    } else if rotation < -π {
      rotation += 2 * π
    }
    delegate?.onPerspectiveChanged(translation: translation, rotation: rotation, scale: scale)
  }

  var startLocation: CGPoint = .zero
  var startTranslation: CGPoint = .zero
  var startScale: CGFloat = 1
  @objc public func pinch() {
    switch pinchGR.state {
    case .began:
      startLocation = pinchGR.location(in: nil)
      startTranslation = translation
      startScale = scale
      fallthrough
    case .changed:
      if pinchGR.numberOfTouches >= 2 {
        scale = min(1, max(0.2, startScale * pinchGR.scale))
        translation = startTranslation + pinchGR.location(in: nil) - startLocation
        delegate?.onPerspectiveChanged(translation: translation, rotation: rotation, scale: scale)
      }
    default:
      break
    }
  }

  @objc public func onDone() {
    delegate?.onDone()
  }
  @objc public func onPerspective() {
    perspectiveButton.isSelected = !perspectiveButton.isSelected
    delegate?.on3D(wants3D: perspectiveButton.isSelected)
  }
  @objc public func onDisplayArcCurve() {
    arcCurveButton!.isSelected = !arcCurveButton!.isSelected
    delegate?.onDisplayArcCurve(wantsCurve: arcCurveButton!.isSelected)
  }
  @objc public func onSlide() {
    delegate?.onProcessSliderChanged(progress: debugSlider.value)
  }
}

extension HeroDebugView: UIGestureRecognizerDelegate {
  public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return perspectiveButton.isSelected
  }
}
#endif
