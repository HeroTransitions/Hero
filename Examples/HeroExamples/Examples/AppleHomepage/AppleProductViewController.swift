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
import Hero

let viewControllerIDs = ["iphone", "watch", "macbook"]

class AppleProductViewController: UIViewController, HeroViewControllerDelegate {
  var panGR: UIPanGestureRecognizer!

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var primaryLabel: UILabel!
  @IBOutlet weak var secondaryLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    panGR = UIPanGestureRecognizer(target: self, action: #selector(pan))
    view.addGestureRecognizer(panGR)
  }

  func applyShrinkModifiers() {
    view.heroModifiers = nil
    primaryLabel.heroModifiers = [.translate(x:-50, y:(view.center.y - primaryLabel.center.y)/10), .scale(0.9), HeroModifier.duration(0.3)]
    secondaryLabel.heroModifiers = [.translate(x:-50, y:(view.center.y - secondaryLabel.center.y)/10), .scale(0.9), HeroModifier.duration(0.3)]
    imageView.heroModifiers = [.translate(x:-80), .scale(0.9), HeroModifier.duration(0.3)]
  }

  func applySlideModifiers() {
    view.heroModifiers = [.translate(x: view.bounds.width), .duration(0.3), .beginWith(modifiers: [.zPosition(2)])]
    primaryLabel.heroModifiers = [.translate(x:100), .duration(0.3)]
    secondaryLabel.heroModifiers = [.translate(x:100), .duration(0.3)]
    imageView.heroModifiers = nil
  }

  enum TransitionState {
    case normal, slidingLeft, slidingRight
  }
  var state: TransitionState = .normal
  weak var nextVC: AppleProductViewController?

  func pan() {
    let translateX = panGR.translation(in: nil).x
    let velocityX = panGR.velocity(in: nil).x
    switch panGR.state {
    case .began, .changed:
      let nextState: TransitionState
      if state == .normal {
        nextState = velocityX < 0 ? .slidingLeft : .slidingRight
      } else {
        nextState = translateX < 0 ? .slidingLeft : .slidingRight
      }

      if nextState != state {
        Hero.shared.cancel(animate: false)
        let currentIndex = viewControllerIDs.index(of: self.title!)!
        let nextIndex = (currentIndex + (nextState == .slidingLeft ? 1 : viewControllerIDs.count - 1)) % viewControllerIDs.count
        nextVC = self.storyboard!.instantiateViewController(withIdentifier: viewControllerIDs[nextIndex]) as? AppleProductViewController

        if nextState == .slidingLeft {
          applyShrinkModifiers()
          nextVC!.applySlideModifiers()
        } else {
          applySlideModifiers()
          nextVC!.applyShrinkModifiers()
        }
        state = nextState
        hero_replaceViewController(with: nextVC!)
      } else {
        let progress = abs(Double(translateX / view.bounds.width))
        Hero.shared.update(progress: progress)
        if state == .slidingLeft, let nextVC = nextVC {
          Hero.shared.apply(modifiers: [.translate(x: view.bounds.width + translateX)], to: nextVC.view)
        } else {
          Hero.shared.apply(modifiers: [.translate(x: translateX)], to: view)
        }
      }
    default:
      let progress = (translateX + velocityX) / view.bounds.width
      if (progress < 0) == (state == .slidingLeft) && abs(progress) > 0.3 {
        Hero.shared.end()
      } else {
        Hero.shared.cancel()
      }
      state = .normal
    }
  }

  func heroWillStartAnimatingTo(viewController: UIViewController) {
    if !(viewController is AppleProductViewController) {
      view.heroModifiers = [.ignoreSubviewModifiers(recursive: true)]
    }
  }
}
