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

class ImageViewController: UICollectionViewController {
  var selectedIndex: IndexPath?
  var panGR = UIPanGestureRecognizer()

  override func viewDidLoad() {
    super.viewDidLoad()
    automaticallyAdjustsScrollViewInsets = false
    preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.width)

    view.layoutIfNeeded()
    collectionView!.reloadData()
    if let selectedIndex = selectedIndex {
      collectionView!.scrollToItem(at: selectedIndex, at: .centeredHorizontally, animated: false)
    }

    panGR.addTarget(self, action: #selector(pan))
    panGR.delegate = self
    collectionView?.addGestureRecognizer(panGR)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    for v in (collectionView!.visibleCells as? [ScrollingImageCell])! {
      v.topInset = topLayoutGuide.length
    }
  }

  func pan() {
    let translation = panGR.translation(in: nil)
    let progress = translation.y / 2 / collectionView!.bounds.height
    switch panGR.state {
    case .began:
      hero_dismissViewController()
    case .changed:
      Hero.shared.update(progress: Double(progress))
      if let cell = collectionView?.visibleCells[0]  as? ScrollingImageCell {
        let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
        Hero.shared.apply(modifiers: [.position(currentPos)], to: cell.imageView)
      }
    default:
      if progress + panGR.velocity(in: nil).y / collectionView!.bounds.height > 0.3 {
        Hero.shared.end()
      } else {
        Hero.shared.cancel()
      }
    }
  }
}

extension ImageViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return ImageLibrary.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let imageCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as? ScrollingImageCell)!
    imageCell.image = ImageLibrary.image(index:indexPath.item)
    imageCell.imageView.heroID = "image_\(indexPath.item)"
    imageCell.imageView.heroModifiers = [.position(CGPoint(x:view.bounds.width/2, y:view.bounds.height+view.bounds.width/2)), .scale(0.6), .fade]
    imageCell.topInset = topLayoutGuide.length
    imageCell.imageView.isOpaque = true
    return imageCell
  }
}

extension ImageViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return view.bounds.size
  }
}

extension ImageViewController:UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let cell = collectionView?.visibleCells[0] as? ScrollingImageCell,
       cell.scrollView.zoomScale == 1 {
      let v = panGR.velocity(in: nil)
      return v.y > abs(v.x)
    }
    return false
  }
}
