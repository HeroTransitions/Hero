//
//  ImageGalleryViewController.swift
//  HeroExamples
//
//  Created by YiLun Zhao on 2016-12-02.
//  Copyright © 2016 Luke Zhao. All rights reserved.
//

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
    let next = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageGallery") as! ImageGalleryViewController
    next.columns = columns == 3 ? 5 : 3
    heroReplaceViewController(with: next)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let currentCell = sender as? ImageCell,
      let vc = segue.destination as? ImageViewController,
      let currentCellIndex = collectionView.indexPath(for: currentCell){
      vc.selectedIndex = currentCellIndex
    }
  }
}

extension ImageGalleryViewController:UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 50
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! ImageCell
    imageCell.imageView.image = UIImage(named: "Unsplash\(indexPath.item % 10)_thumb")
    imageCell.heroID = "image_\(indexPath.item)"
    imageCell.heroModifiers = "fade translate(0, 150) rotate(-1,0,0) scale(0.8) zPosition(50) zPositionIfMatched(100)"
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
    // NOTE: matched views(same heroID on both View controllers) won't have 
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
