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
import AVKit
import AVFoundation

class AVPlayerView: UIView {
  override class var layerClass: Swift.AnyClass {
    return AVPlayerLayer.self
  }
}

class VideoPlayerViewController: UIViewController {
  var playerView: UIView!
  var panGR: UIPanGestureRecognizer!

  override func viewDidLoad() {
    super.viewDidLoad()
    let player = AVPlayer(url: URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!)

    playerView = AVPlayerView(frame: view.bounds)
    playerView.backgroundColor = .black
    (playerView.layer as! AVPlayerLayer).player = player
    playerView.heroID = "videoPlayer"
    playerView.heroModifiers = [.useNoSnapshot, .useScaleBasedSizeChange]
    view.insertSubview(playerView, at: 0)

    panGR = UIPanGestureRecognizer(target: self, action: #selector(pan))
    view.addGestureRecognizer(panGR)

    // skip the initial splash screen of the video
    player.seek(to: CMTimeMakeWithSeconds(0.35, 1000), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    player.play()
  }

  func pan() {
    let translation = panGR.translation(in: nil)
    let progress = translation.y / 2 / view.bounds.height
    switch panGR.state {
    case .began:
      hero_dismissViewController()
    case .changed:
      Hero.shared.update(progress: Double(progress))
      let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
      Hero.shared.apply(modifiers: [.position(currentPos)], to: playerView)
    default:
      if progress + panGR.velocity(in: nil).y / view.bounds.height > 0.3 {
        Hero.shared.end()
      } else {
        Hero.shared.cancel()
      }
    }
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    playerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width / 16 * 9)
    playerView.center = view.center
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // must re-insert the playerView since we used .useNoSnapshot modifier on it.
    // Hero will take it out of the view hierarchy during the transition.
    playerView.frame = view.bounds
    view.insertSubview(playerView, at: 0)
  }
}
