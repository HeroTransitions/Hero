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

class ImageGalleryViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  var columns = 3
  lazy var cellSize:CGSize = CGSize(width: self.view.bounds.width/CGFloat(self.columns),
                                    height: self.view.bounds.width/CGFloat(self.columns))

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.reloadData()
    collectionView.indicatorStyle = .white
  }

  @IBAction func switchLayout(_ sender: Any) {
    // just replace the root view controller with the same view controller
    // animation is automatic! Holy
    let next = UIStoryboard(name: "ImageGallery", bundle: nil).instantiateViewController(withIdentifier: "imageGallery") as! ImageGalleryViewController
    next.columns = columns == 3 ? 5 : 3
    heroReplaceViewController(with: next)
  }
}

extension ImageGalleryViewController:UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = viewController(forStoryboardName: "ImageViewer") as! ImageViewController
    vc.selectedIndex = indexPath
    navigationController!.pushViewController(vc, animated: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 50
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! ImageCell
    imageCell.imageView.image = UIImage(named: "Unsplash\(indexPath.item % 10)_thumb")
    imageCell.heroID = "image_\(indexPath.item)"
    imageCell.heroModifiers = HeroComposition().fade().translate(x: 0, y: 150).rotate(x: -1, y: 0, z: 0).scale(s: 0.8).zPosition(z: 50).zPositionIfMatched(z: 100).modifier
    return imageCell
  }
}

extension ImageGalleryViewController:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
  }
}

extension ImageGalleryViewController:HeroViewControllerDelegate{
  func heroWillStartAnimatingTo(viewController: UIViewController) {
    // Cascade effect when transition to another view controller
    // This adds increasing delays for collectionView's subviews
    // the first parameter is the delay in between each animation
    // the second parameter is the cascade direction
    // the third is the initial delay
    // the forth is whether or not to delay matched views
    //
    // NOTE: matched views(views with the same `heroID`) won't have
    // the cascading effect. however, you can use the 4th parameter to delay
    // the start time until the last cascading animation have started
    // by default: the matched views will animate simutanously with the cascading views
    if (viewController as? ImageGalleryViewController) != nil || (viewController as? ImageViewController) != nil{
      collectionView.heroModifiers = "cascade(0.015, bottomToTop, 0, true)"
    } else {
      collectionView.heroModifiers = "cascade(0.015, topToBottom)"
    }
  }
  func heroWillStartAnimatingFrom(viewController: UIViewController) {
    if (viewController as? ImageGalleryViewController) != nil{
      collectionView.heroModifiers = "cascade(0.015, topToBottom, 0.25)"
    } else {
      collectionView.heroModifiers = "cascade(0.015, topToBottom)"
    }
    if let vc = viewController as? ImageViewController,
      let originalCellIndex = vc.selectedIndex,
      let currentCellIndex = vc.collectionView?.indexPathsForVisibleItems[0] {
      if !collectionView.indexPathsForVisibleItems.contains(currentCellIndex){
        // make the cell visible
        collectionView.scrollToItem(at: currentCellIndex,
                                    at: originalCellIndex < currentCellIndex ? .bottom : .top,
                                    animated: false)
      }
    }
  }
}
