//
//  ImageViewController.swift
//  HeroExamples
//
//  Created by YiLun Zhao on 2016-12-02.
//  Copyright © 2016 Luke Zhao. All rights reserved.
//

import UIKit
import Hero

class ImageViewController: UICollectionViewController {
  var selectedIndex:IndexPath?
  var panGR = UIPanGestureRecognizer()
  weak var interactiveContext:HeroInteractiveContext?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    automaticallyAdjustsScrollViewInsets = false
    preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.width)
    
    view.layoutIfNeeded()
    collectionView!.reloadData()
    if let selectedIndex = selectedIndex{
      collectionView!.scrollToItem(at: selectedIndex, at: .centeredHorizontally, animated: false)
    }
    
    panGR.addTarget(self, action: #selector(pan))
    panGR.delegate = self
    collectionView?.addGestureRecognizer(panGR)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    for v in collectionView!.visibleCells as! [ScrollingImageCell]{
      v.topInset = topLayoutGuide.length
    }
  }
  
  func pan(){
    let translation = panGR.translation(in: nil)
    let progress = translation.y / 2 / collectionView!.bounds.height
    switch panGR.state {
    case .began:
      if let nav = navigationController, nav.viewControllers.first != self{
        let _ = nav.popViewController(animated: true)
      } else {
        dismiss(animated: true, completion: nil)
      }
    case .changed:
      interactiveContext?.update(progress: Double(progress))
      if let cell = collectionView?.visibleCells[0]  as? ScrollingImageCell{
        let currentPos = translation + view.center
        interactiveContext?.temporarilySet(view: cell.imageView, with: "position(\(currentPos.x), \(currentPos.y))")
      }
    default:
      if progress + panGR.velocity(in: nil).y / collectionView!.bounds.height > 0.15{
        interactiveContext?.end()
      } else {
        interactiveContext?.cancel()
      }
      interactiveContext = nil
    }
  }
}

extension ImageViewController{
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 50
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! ScrollingImageCell
    imageCell.imageView.image = UIImage(named: "Unsplash\(indexPath.item % 10)")
    imageCell.imageView.heroID = "image_\(indexPath.item)"
    imageCell.imageView.heroModifiers = "position(\(view.bounds.width/2), \(view.bounds.height+view.bounds.width/2)) scale(0.6) fade zPositionIfMatched(100)"
    imageCell.topInset = topLayoutGuide.length
    return imageCell
  }
}

extension ImageViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return view.bounds.size
  }
}

extension ImageViewController:UIGestureRecognizerDelegate{
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let cell = collectionView?.visibleCells[0] as? ScrollingImageCell,
       cell.scrollView.zoomScale == 1 {
      let v = panGR.velocity(in: nil)
      return v.y > abs(v.x)
    }
    return false
  }
}

extension ImageViewController:HeroViewControllerDelegate{
  func wantInteractiveHeroTransition(context: HeroInteractiveContext) -> Bool {
    if !context.presenting && panGR.state == .began{
      interactiveContext = context
      return true
    }
    return false
  }
}
